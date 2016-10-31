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

/**
 * The <code>SurveyRequestStatus</code> enumeration defines the possible statuses for a survey
 * request.
 *
 * @author Marcus Portmann
 */
public enum SurveyRequestStatus
{
  UNKNOWN(0, "Unknown"), QUEUED_FOR_SENDING(1, "QueuedForSending"), SENDING(2, "Sending"), SENT(3,
      "Sent"), FAILED(4, "Failed"), ANY(-1, "Any");

  private String description;
  private int code;

  SurveyRequestStatus(int code, String description)
  {
    this.code = code;
    this.description = description;
  }

  /**
   * Returns the survey request status given by the specified numeric code value.
   *
   * @param code the numeric code value identifying the survey request status
   *
   * @return the survey request status given by the specified numeric code value
   */
  public static SurveyRequestStatus fromCode(int code)
  {
    switch (code)
    {
      case 1:
        return SurveyRequestStatus.QUEUED_FOR_SENDING;

      case 2:
        return SurveyRequestStatus.SENDING;

      case 3:
        return SurveyRequestStatus.SENT;

      case 4:
        return SurveyRequestStatus.FAILED;

      default:
        return SurveyRequestStatus.UNKNOWN;
    }
  }

  /**
   * Returns the numeric code for the survey request status.
   *
   * @return the numeric code for the survey request status
   */
  public int code()
  {
    return code;
  }

  /**
   * Returns the description for the survey request status.
   *
   * @return the description for the survey request status
   */
  public String description()
  {
    return description;
  }

  /**
   * Returns the <code>String</code> representation of the numeric code for the survey request
   * status.
   *
   * @return the <code>String</code> representation of the numeric code for the survey request
   *         status
   */
  public String getCodeAsString()
  {
    return String.valueOf(code);
  }
}
