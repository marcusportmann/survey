/*
 * Copyright 2016 Marcus Portmann
 * All rights reserved.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package digital.survey.model;

//~--- non-JDK imports --------------------------------------------------------

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import javax.inject.Inject;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>BackgroundSurveyRequestSender</code> class implements the Background Survey Request
 * Sender.
 *
 * @author Marcus Portmann
 */
@Service
@SuppressWarnings("unused")
public class BackgroundSurveyRequestSender
{
  /* Logger */
  private static Logger logger = LoggerFactory.getLogger(BackgroundSurveyRequestSender.class);

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * Initialise the Background Survey Request Sender.
   */
  @PostConstruct
  public void init()
  {
    logger.info("Initialising the Background Survey Request Sender");

    if (surveyService != null)
    {
      // Reset the locks for any survey requests that were previously being sent
      try
      {
        logger.info("Resetting the locks for any survey requests that were previously being sent");

        surveyService.resetSurveyRequestLocks(SurveyRequestStatus.SENDING, SurveyRequestStatus
            .QUEUED_FOR_SENDING);
      }
      catch (Throwable e)
      {
        logger.error(
            "Failed to reset the locks for any survey requests that were previously being sent", e);
      }
    }
    else
    {
      logger.error("Failed to initialise the Background Survey Request Sender:"
          + " The Survey Service was NOT injected");
    }
  }

  /**
   * Send the survey requests.
   */
  @Scheduled(cron = "0 * * * * *")
  @Async
  public void sendSurveyRequests()
  {
    SurveyRequest surveyRequest;

    while (true)
    {
      // Retrieve the next survey request that is queued for sending
      try
      {
        surveyRequest = surveyService.getNextSurveyRequestQueuedForSending();

        if (surveyRequest == null)
        {
          if (logger.isDebugEnabled())
          {
            logger.debug("No survey requests are queued for sending");
          }

          return;
        }
      }
      catch (Throwable e)
      {
        logger.error("Failed to retrieve the next survey request that is queued for sending", e);

        return;
      }

      // Send the survey request
      try
      {
        if (logger.isDebugEnabled())
        {
          logger.debug(String.format("Sending the survey request (%s)", surveyRequest.getId()));
        }

        if (surveyService.sendSurveyRequest(surveyRequest))
        {
          // Unlock the survey request and mark it as sent
          surveyService.unlockSurveyRequest(surveyRequest.getId(), SurveyRequestStatus.SENT);
        }
        else
        {
          // Unlock the survey request and mark it as failed
          surveyService.unlockSurveyRequest(surveyRequest.getId(), SurveyRequestStatus.FAILED);
        }
      }
      catch (Throwable e)
      {
        logger.error(String.format("Failed to send the survey request (%s)",
            surveyRequest.getId()), e);

        // Increment the send attempts for the survey request
        try
        {
          surveyService.incrementSurveyRequestSendAttempts(surveyRequest);
        }
        catch (Throwable f)
        {
          logger.error(String.format(
              "Failed to increment the send attempts for the survey request (%s)",
              surveyRequest.getId()), f);
        }

        try
        {
          /*
           * If the survey request has exceeded the maximum number of send attempts then unlock it
           * and set its status to "Failed" otherwise unlock it and set its status to
           * "QueuedForSending".
           */
          if (surveyRequest.getSendAttempts()
              >= surveyService.getMaximumSurveyRequestSendAttempts())
          {
            logger.warn(String.format("The survey request (%s) has exceeded the maximum number of"
                + " send attempts and will be marked as \"Failed\"", surveyRequest.getId()));

            surveyService.unlockSurveyRequest(surveyRequest.getId(), SurveyRequestStatus.FAILED);
          }
          else
          {
            surveyService.unlockSurveyRequest(surveyRequest.getId(), SurveyRequestStatus
                .QUEUED_FOR_SENDING);
          }
        }
        catch (Throwable f)
        {
          logger.error(String.format(
              "Failed to unlock and set the status for the survey request (%s)",
              surveyRequest.getId()), f);
        }
      }
    }
  }
}
