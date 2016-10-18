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

package guru.mmp.survey.model;

//~--- non-JDK imports --------------------------------------------------------

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;

/**
 * The <code>SurveyGroupRatingItemType</code> class implements the Survey Group Definition Rating
 * Type entity, which represents a type of group rating item that can form part of a survey definition.
 *
 * @author Marcus Portmann
 */
public enum SurveyGroupRatingItemType
{
  PERCENTAGE(1, "Percentage"), YES_NO_NA(2, "Yes/No/NA");

  private String description;
  private int code;

  SurveyGroupRatingItemType(int code, String description)
  {
    this.code = code;
    this.description = description;
  }

  /**
   * Returns the survey group rating item type given by the specified numeric code value.
   *
   * @param code the numeric code value identifying the survey group rating item type
   *
   * @return the survey group rating item type given by the specified numeric code value
   */
  @JsonCreator
  public static SurveyGroupRatingItemType fromCode(int code)
  {
    switch (code)
    {
      case 1:
        return SurveyGroupRatingItemType.PERCENTAGE;

      case 2:
        return SurveyGroupRatingItemType.YES_NO_NA;

      default:
        return SurveyGroupRatingItemType.PERCENTAGE;
    }
  }

  /**
   * Returns the numeric code for the survey group rating item type.
   *
   * @return the numeric code for the survey group rating item type
   */
  @JsonValue
  public int code()
  {
    return code;
  }

  /**
   * Returns the default rating for the survey group rating item type.
   *
   * @return the default rating for the survey group rating item type
   */
  public int defaultRating()
  {
    switch (code)
    {
      case 1:
        return 0;

      case 2:
        return -1;

      default:
        return 0;
    }
  }

  /**
   * Returns the description for the survey group rating item type.
   *
   * @return the description for the survey group rating item type
   */
  public String description()
  {
    return description;
  }
}
