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

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;

/**
 * The <code>YesNoNaRating</code> class provides the possible ratings for a Yes/No/NA Rating
 * survey group rating.
 *
 * @author Marcus Portmann
 */
public enum YesNoNaRating
{
  NA(-1, "N/A"), NO(0, "No"), YES(1, "Yes");

  private String description;
  private int code;

  YesNoNaRating(int code, String description)
  {
    this.code = code;
    this.description = description;
  }

  /**
   * Returns the yes/no/na rating given by the specified numeric code value.
   *
   * @param code the numeric code value identifying the yes/no/na rating
   *
   * @return the yes/no/na rating given by the specified numeric code value
   */
  @JsonCreator
  public static YesNoNaRating fromCode(int code)
  {
    switch (code)
    {
      case -1:
        return YesNoNaRating.NA;

      case 0:
        return YesNoNaRating.NO;

      case 1:
        return YesNoNaRating.YES;

      default:
        return YesNoNaRating.NA;
    }
  }

  /**
   * Returns the numeric code for the yes/no/na rating.
   *
   * @return the numeric code for the yes/no/na rating
   */
  @JsonValue
  public int code()
  {
    return code;
  }

  /**
   * Returns the description for the yes/no/na rating.
   *
   * @return the description for the yes/no/na rating
   */
  public String description()
  {
    return description;
  }
}
