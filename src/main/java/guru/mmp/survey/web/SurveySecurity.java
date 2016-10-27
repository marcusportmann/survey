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

package guru.mmp.survey.web;

/**
 * The <code>SurveySecurity</code> class provides access to the security-related information
 * and functionality for the web application. This includes a list of the authorized
 * function codes.
 *
 * @author Marcus Portmann
 */
public class SurveySecurity
{
  /** The Survey.SurveyAudienceAdministration function code */
  public static final String FUNCTION_CODE_SURVEY_AUDIENCE_ADMINISTRATION =
      "Survey.SurveyAudienceAdministration";

  /** The Survey.SurveyAdministration function code */
  public static final String FUNCTION_CODE_SURVEY_ADMINISTRATION =
    "Survey.SurveyAdministration";

  /** The Survey.ViewSurveyResponse function code */
  public static final String FUNCTION_CODE_VIEW_SURVEY_RESPONSE =
    "Survey.ViewSurveyResponse";
}
