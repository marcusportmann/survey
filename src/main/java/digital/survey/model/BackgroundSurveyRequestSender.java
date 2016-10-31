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

import javax.annotation.PostConstruct;
import javax.ejb.*;
import javax.enterprise.context.ApplicationScoped;
import javax.enterprise.inject.Default;
import javax.inject.Inject;
import java.util.concurrent.Future;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>BackgroundSurveyRequestSender</code> class implements the Background Survey Request
 * Sender.
 *
 * @author Marcus Portmann
 */
@ApplicationScoped
@Default
@ConcurrencyManagement(ConcurrencyManagementType.BEAN)
@TransactionManagement(TransactionManagementType.BEAN)
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
   * Send all survey requests that are queued for sending.
   *
   * @return <code>true</code> if the survey requests were sent successfully or
   *         <code>false</code> otherwise
   */
  @Asynchronous
  public Future<Boolean> send()
  {
    // If CDI injection was not completed successfully for the bean then stop here
    if (surveyService == null)
    {
      logger.error("Failed to send the survey requests queued for sending:"
          + " The SurveyService was NOT injected");

      return new AsyncResult<>(false);
    }

    try
    {
      sendSurveyRequests();

      return new AsyncResult<>(true);
    }
    catch (Throwable e)
    {
      logger.error("Failed to send the survey requests queued for sending", e);

      return new AsyncResult<>(false);
    }
  }

  private void sendSurveyRequests()
  {
    SurveyRequest surveyRequest;

    while (true)
    {
      // Retrieve the next survey request that is queued for sending
      try
      {
        surveyRequest = surveyRequest.getNextSurveyRequestQueuedForSending();

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

        if (surveyService.sendSurveyRequest(surveyRequest));
        {
          // Delete the SMS
          smsService.deleteSMS(sms.getId());
        }
        else
        {
          // Unlock the SMS and mark it as failed
          smsService.unlockSMS(sms.getId(), SMS.Status.FAILED);
        }
      }
      catch (Throwable e)
      {
        logger.error(String.format("Failed to send the queued survy request (%s)",
            surveyRequest.getId()), e);

        // Increment the send attempts for the SMS
        try
        {
          smsService.incrementSMSSendAttempts(sms);
        }
        catch (Throwable f)
        {
          logger.error(String.format(
              "Failed to increment the send attempts for the queued survey request (%s)",
              surveyRequest.getId()), f);
        }

        try
        {
          /*
           * If the SMS has exceeded the maximum number of processing attempts then unlock it
           * and set its status to "Failed" otherwise unlock it and set its status to
           * "QueuedForSending".
           */
          if (sms.getSendAttempts() >= smsService.getMaximumSendAttempts())
          {
            logger.warn(String.format(
                "The queued survey request (%s) has exceeded the maximum number of send attempts"
                + " and will be marked as \"Failed\"", surveyRequest.getId()));

            smsService.unlockSMS(sms.getId(), SMS.Status.FAILED);
          }
          else
          {
            smsService.unlockSMS(sms.getId(), SMS.Status.QUEUED_FOR_SENDING);
          }
        }
        catch (Throwable f)
        {
          logger.error(String.format(
              "Failed to unlock and set the status for the queued survey request (%s)",
              surveyRequest.getId()), f);
        }
      }
    }
  }
}
