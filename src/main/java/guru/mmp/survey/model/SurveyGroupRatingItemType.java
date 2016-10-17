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
   * Returns the survey group definition rating type given by the specified numeric code value.
   *
   * @param code the numeric code value identifying the survey group definition rating type
   *
   * @return the survey group definition rating type given by the specified numeric code value
   */
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
   * Returns the numeric code for the survey group definition rating type.
   *
   * @return the numeric code for the survey group definition rating type
   */
  public int code()
  {
    return code;
  }

  /**
   * Returns the description for the survey group definition rating type.
   *
   * @return the description for the survey group definition rating type
   */
  public String description()
  {
    return description;
  }
}
