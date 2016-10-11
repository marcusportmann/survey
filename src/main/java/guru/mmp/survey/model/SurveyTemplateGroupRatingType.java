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
 * The <code>SurveyTemplateGroupRatingType</code> class implements the Survey Template Group Rating
 * Type entity, which represents represents a group rating type for a group rating that forms part
 * of a template for a survey.
 *
 * @author Marcus Portmann
 */
public enum SurveyTemplateGroupRatingType
{
  PERCENTAGE(1, "Percentage"), YES_NO_NA(2, "Yes/No/NA");

  private String description;
  private int code;

  SurveyTemplateGroupRatingType(int code, String description)
  {
    this.code = code;
    this.description = description;
  }

  /**
   * Returns the survey template group rating type given by the specified numeric code value.
   *
   * @param code the numeric code value identifying the survey template group rating type
   *
   * @return the survey template group rating type given by the specified numeric code value
   */
  public static SurveyTemplateGroupRatingType fromCode(int code)
  {
    switch (code)
    {
      case 1:
        return SurveyTemplateGroupRatingType.PERCENTAGE;

      case 2:
        return SurveyTemplateGroupRatingType.YES_NO_NA;

      default:
        return SurveyTemplateGroupRatingType.PERCENTAGE;
    }
  }

  /**
   * Returns the numeric code for the survey template group rating type.
   *
   * @return the numeric code for the survey template group rating type
   */
  public int code()
  {
    return code;
  }

  /**
   * Returns the description for the survey template group rating type.
   *
   * @return the description for the survey template group rating type
   */
  public String description()
  {
    return description;
  }
}
