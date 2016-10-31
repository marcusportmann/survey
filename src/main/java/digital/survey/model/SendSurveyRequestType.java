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
 * The <code>SendSurveyRequestType</code> enumeration defines the types of survey requests that can
 * be sent.
 *
 * @author Marcus Portmann
 */
public enum SendSurveyRequestType
{
  PERSON(1, "Person"), AUDIENCE(2, "Audience");

  private String description;
  private int code;

  SendSurveyRequestType(int code, String description)
  {
    this.code = code;
    this.description = description;
  }

  /**
   * Returns the send survey request type given by the specified numeric code value.
   *
   * @param code the numeric code value identifying the send survey request type
   *
   * @return the send survey request type given by the specified numeric code value
   */
  public static SendSurveyRequestType fromCode(int code)
  {
    switch (code)
    {
      case 1:
        return SendSurveyRequestType.PERSON;

      case 2:
        return SendSurveyRequestType.AUDIENCE;

      default:
        return SendSurveyRequestType.PERSON;
    }
  }

  /**
   * Returns the numeric code for the send survey request type.
   *
   * @return the numeric code for the send survey request type
   */
  public int code()
  {
    return code;
  }

  /**
   * Returns the description for the send survey request type.
   *
   * @return the description for the send survey request type
   */
  public String description()
  {
    return description;
  }

  /**
   * Returns the <code>String</code> representation of the numeric code for the send survey request
   * type.
   *
   * @return the <code>String</code> representation of the numeric code for the send survey request
   *         type
   */
  public String getCodeAsString()
  {
    return String.valueOf(code);
  }
}
