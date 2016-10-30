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

//~--- JDK imports ------------------------------------------------------------

import java.io.Serializable;
import java.util.Date;
import java.util.UUID;

/**
 * The <code>SurveyRequestToSurveyResponseMapping</code> class implements the POJO class that
 * stores the mapping between the ID for a survey request and its associated survey response ID.
 *
 * @author Marcus Portmann
 */
public class SurveyRequestToSurveyResponseMapping
  implements Serializable
{
  /**
   * The date and time the request to complete the survey was last sent.
   */
  private Date requested;

  /**
   * The date and time the survey response was received.
   */
  private Date responded;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey request.
   */
  private UUID requestId;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey response.
   */
  private UUID responseId;

  /**
   * Constructs a new <code>SurveyRequestToSurveyResponseMapping</code>.
   *
   * Default constructor required for JPA.
   */
  @SuppressWarnings("unused")
  SurveyRequestToSurveyResponseMapping() {}

  /**
   * Constructs a new <code>SurveyRequestToSurveyResponseMapping</code>.
   *
   * @param requestId  the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *                   request
   * @param requested  the date and time the request to complete the survey was last sent
   * @param responseId the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *                   response
   * @param responded  the date and time the survey response was received
   */
  @SuppressWarnings("unused")
  public SurveyRequestToSurveyResponseMapping(UUID requestId, Date requested, UUID responseId,
      Date responded)
  {
    this.requestId = requestId;
    this.requested = requested;
    this.responseId = responseId;
    this.responded = responded;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey request.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey request
   */
  public UUID getRequestId()
  {
    return requestId;
  }

  /**
   * Returns the date and time the request to complete the survey was last sent.
   *
   * @return the date and time the request to complete the survey was last sent
   */
  public Date getRequested()
  {
    return requested;
  }

  /**
   * Returns the date and time the survey response was received.
   *
   * @return the date and time the survey response was received
   */
  public Date getResponded()
  {
    return responded;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey response.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey response
   */
  public UUID getResponseId()
  {
    return responseId;
  }
}
