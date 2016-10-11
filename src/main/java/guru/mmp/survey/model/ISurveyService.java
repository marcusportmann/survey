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
 * The <code>ISurveyService</code> interface defines the functionality that must be
 * provided by a Survey Service implementation.
 *
 * @author Marcus Portmann
 */
public interface ISurveyService
{
  /**
   * Retrieve the survey template identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           template
   *
   * @return the survey template identified by the specified ID or <code>null</code> if the
   *         survey template could not be found
   */
  SurveyTemplate getSurveyTemplate(String id)
    throws SurveyServiceException;

  /**
   * Save the survey template.
   *
   * @param surveyTemplate the survey template
   *
   * @return the saved survey template
   *
   * @throws SurveyServiceException
   */
  SurveyTemplate saveSurveyTemplate(SurveyTemplate surveyTemplate)
    throws SurveyServiceException;
}
