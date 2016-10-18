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

//~--- JDK imports ------------------------------------------------------------

import java.util.UUID;

/**
 * The <code>ISurveyService</code> interface defines the functionality that must be
 * provided by a Survey Service implementation.
 *
 * @author Marcus Portmann
 */
public interface ISurveyService
{
  /**
   * Retrieve the survey response identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           response
   *
   * @return the survey response identified by the specified ID or <code>null</code> if the survey
   *         response could not be found
   */
  SurveyResponse getSurveyResponse(UUID id)
    throws SurveyServiceException;

  /**
   * Retrieve the survey definition identified by the specified ID and version.
   *
   * @param id      the Universally Unique Identifier (UUID) used, along with the version of the
   *                survey definition, to uniquely identify the survey definition
   * @param version the version of the survey definition
   *
   * @return the survey definition identified by the specified ID and version or <code>null</code>
   *         if the survey definition could not be found
   */
  SurveyDefinition getSurveyDefinition(UUID id, int version)
    throws SurveyServiceException;

  /**
   * Retrieve the survey instance identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           instance
   *
   * @return the survey instance identified by the specified ID or <code>null</code> if the survey
   *         instance could not be found
   */
  SurveyInstance getSurveyInstance(UUID id)
    throws SurveyServiceException;

  /**
   * Retrieve the survey request identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey request
   *
   * @return the survey request identified by the specified ID or <code>null</code> if the survey
   *         request could not be found
   */
  SurveyRequest getSurveyRequest(UUID id)
    throws SurveyServiceException;

  /**
   * Save the survey definition.
   *
   * @param surveyDefinition the survey definition
   *
   * @return the saved survey definition
   */
  SurveyDefinition saveSurveyDefinition(SurveyDefinition surveyDefinition)
    throws SurveyServiceException;

  /**
   * Save the survey instance.
   *
   * @param surveyInstance the survey instance
   *
   * @return the saved survey instance
   */
  SurveyInstance saveSurveyInstance(SurveyInstance surveyInstance)
    throws SurveyServiceException;

  /**
   * Save the survey response.
   *
   * @param surveyResponse the survey response
   *
   * @return the saved survey response
   */
  SurveyResponse saveSurveyResponse(SurveyResponse surveyResponse)
    throws SurveyServiceException;
}
