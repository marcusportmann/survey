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

/**
 * The <code>SurveyGroupRatingTotalDefinition</code> class implements the Survey Group Rating Total
 * Definition entity, which represents the definition for a survey group rating total , e.g. an
 * average or weighted average of all the ratings for the survey group rating item responses for a
 * survey group member associated with a survey group.
 *
 * @author Marcus Portmann
 */
public class SurveyGroupRatingTotalDefinition extends SurveyGroupRatingItemDefinition
{
  /**
   * Constructs a new <code>SurveyGroupRatingTotalDefinition</code>.
   *
   * @param name                       the name of the survey group rating total definition
   * @param ratingType                 the type of survey group rating total
   * @param displayRatingUsingGradient should the rating for a survey group rating total be
   *                                   displayed using a color gradient when viewing the survey
   *                                   result
   */
  public SurveyGroupRatingTotalDefinition(String name, SurveyGroupRatingItemType ratingType,
      boolean displayRatingUsingGradient)
  {
    super(null, name, null, ratingType, displayRatingUsingGradient);
  }
}
