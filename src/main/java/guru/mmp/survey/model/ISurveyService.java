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

import java.util.List;
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
   * Retrieve the latest versions of the filtered survey definitions for the organisation.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the
   *               organisation
   * @param filter the filter used to limit the matching survey definitions
   *
   * @return the latest versions of the filtered survey definitions for the organisation
   */
  List<SurveyDefinition> getFilteredLatestSurveyDefinitionsForOrganisation(UUID id, String filter)
    throws SurveyServiceException;

  /**
   * Retrieve the filtered survey audience members for the survey audience.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *               audience
   * @param filter the filter used to limit the matching survey audience members
   *
   * @return the filtered survey audiences members for the survey audience
   */
  List<SurveyAudienceMember> getFilteredMembersForSurveyAudience(UUID id, String filter)
    throws SurveyServiceException;

  /**
   * Retrieve the filtered survey audiences for the organisation.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the
   *               organisation
   * @param filter the filter used to limit the matching survey audiences
   *
   * @return the filtered survey audiences for the organisation
   */
  List<SurveyAudience> getFilteredSurveyAudiencesForOrganisation(UUID id, String filter)
    throws SurveyServiceException;

  /**
   * Retrieve the filtered survey instances for all versions of the survey definition.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey definition
   *               the survey instances are associated with
   * @param filter the filter used to limit the matching survey definitions
   *
   * @return the filtered survey instances for all versions of the survey definition
   */
  List<SurveyInstance> getFilteredSurveyInstancesForSurveyDefinition(UUID id, String filter)
    throws SurveyServiceException;

  /**
   * Retrieve the filtered survey requests for the survey instance.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey instance
   *               the survey requests are associated with
   * @param filter the filter used to limit the matching survey requests
   *
   * @return the filtered survey requests for the survey instance
   */
  List<SurveyRequest> getFilteredSurveyRequestsForSurveyInstance(UUID id, String filter)
    throws SurveyServiceException;

  /**
   * Retrieve the filtered survey responses for the survey instance.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey instance
   *               the survey responses are associated with
   * @param filter the filter used to limit the matching survey responses
   *
   * @return the filtered survey responses for the survey instance
   */
  List<SurveyResponse> getFilteredSurveyResponsesForSurveyInstance(UUID id, String filter)
    throws SurveyServiceException;

  /**
   * Retrieve the latest versions of the survey definitions for the organisation.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the organisation
   *
   * @return the latest versions of the survey definitions for the organisation
   */
  List<SurveyDefinition> getLatestSurveyDefinitionsForOrganisation(UUID id)
    throws SurveyServiceException;

  /**
   * Retrieve the latest version for the survey definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey definition
   *
   * @return the latest version for the survey definition or <code>null</code> if the survey
   *         definition could not be found
   */
  SurveyDefinition getLatestVersionForSurveyDefinition(UUID id)
    throws SurveyServiceException;

  /**
   * Retrieve the latest version number for the survey definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey definition
   *
   * @return the latest version number for the survey definition or 0 if the survey definition
   *         could not be found
   */
  int getLatestVersionNumberForSurveyDefinition(UUID id)
    throws SurveyServiceException;

  /**
   * Retrieve the survey audience members for the survey audience.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           audience
   *
   * @return the survey audiences members for the survey audience
   */
  List<SurveyAudienceMember> getMembersForSurveyAudience(UUID id)
    throws SurveyServiceException;

  /**
   * Retrieve the number of latest versions of the filtered survey definitions for the organisation.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the
   *               organisation
   * @param filter the filter used to limit the matching survey definitions
   *
   * @return the number of latest versions of the filtered survey definitions for the organisation
   */
  int getNumberOfFilteredLatestSurveyDefinitionsForOrganisation(UUID id, String filter)
    throws SurveyServiceException;

  /**
   * Returns the number of filtered survey audience members for the survey audience.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *               audience
   * @param filter the filter used to limit the matching survey audience members
   *
   * @return the number of filtered survey audience members for the survey audience
   */
  int getNumberOfFilteredMembersForSurveyAudience(UUID id, String filter)
    throws SurveyServiceException;

  /**
   * Returns the number of filtered survey audiences for the organisation.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the
   *               organisation
   * @param filter the filter used to limit the matching survey audiences
   *
   * @return the number of filtered survey audiences for the organisation
   */
  int getNumberOfFilteredSurveyAudiencesForOrganisation(UUID id, String filter)
    throws SurveyServiceException;

  /**
   * Retrieve the number of filtered survey instances for all versions of the survey definition.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey definition
   *               the survey instances are associated with
   * @param filter the filter used to limit the matching survey definitions
   *
   * @return the number of filtered survey instances for all versions of the survey definition
   */
  int getNumberOfFilteredSurveyInstancesForSurveyDefinition(UUID id, String filter)
    throws SurveyServiceException;

  /**
   * Retrieve the number of filtered survey requests for the survey instance.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey instance
   *               the survey requests are associated with
   * @param filter the filter used to limit the matching survey requests
   *
   * @return the number of filtered survey requests for the survey instance
   */
  int getNumberOfFilteredSurveyRequestsForSurveyInstance(UUID id, String filter)
    throws SurveyServiceException;

  /**
   * Retrieve the number of filtered survey responses for the survey instance.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey instance
   *               the survey responses are associated with
   * @param filter the filter used to limit the matching survey responses
   *
   * @return the number of filtered survey responses for the survey instance
   */
  int getNumberOfFilteredSurveyResponsesForSurveyInstance(UUID id, String filter)
    throws SurveyServiceException;

  /**
   * Retrieve the number of latest versions of the survey definitions for the organisation.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the organisation
   *
   * @return the number of latest versions of the survey definitions for the organisation
   */
  int getNumberOfLatestSurveyDefinitionsForOrganisation(UUID id)
    throws SurveyServiceException;

  /**
   * Returns the number of members for the survey audience.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           audience
   *
   * @return the number of members for the survey audience
   */
  int getNumberOfMembersForSurveyAudience(UUID id)
    throws SurveyServiceException;

  /**
   * Returns the number of survey audiences for the organisation.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the organisation
   *
   * @return the number of survey audiences for the organisation
   */
  int getNumberOfSurveyAudiencesForOrganisation(UUID id)
    throws SurveyServiceException;

  /**
   * Retrieve the number of survey instances for all versions of the survey definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey definition the
   *           survey instances are associated with
   *
   * @return the number of survey instances for all versions of the survey definition
   */
  int getNumberOfSurveyInstancesForSurveyDefinition(UUID id)
    throws SurveyServiceException;

  /**
   * Retrieve the number of survey requests for the survey instance.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey instance the
   *           survey requests are associated with
   *
   * @return the number of survey requests for the survey instance
   */
  int getNumberOfSurveyRequestsForSurveyInstance(UUID id)
    throws SurveyServiceException;

  /**
   * Retrieve the number of survey responses for the survey instance.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey instance the
   *           survey responses are associated with
   *
   * @return the number of survey responses for the survey instance
   */
  int getNumberOfSurveyResponsesForSurveyInstance(UUID id)
    throws SurveyServiceException;

  /**
   * Retrieve the survey audience identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           audience
   *
   * @return the survey audience identified by the specified ID or <code>null</code> if the survey
   *         audience could not be found
   */
  SurveyAudience getSurveyAudience(UUID id)
    throws SurveyServiceException;

  /**
   * Retrieve the survey audience member identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           audience member
   *
   * @return the survey audience member identified by the specified ID or <code>null</code> if the
   *         survey audience member could not be found
   */
  SurveyAudienceMember getSurveyAudienceMember(UUID id)
    throws SurveyServiceException;

  /**
   * Retrieve the survey audiences for the organisation.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the organisation
   *
   * @return the survey audiences for the organisation
   */
  List<SurveyAudience> getSurveyAudiencesForOrganisation(UUID id)
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
   * Retrieve the survey instances for all versions of the survey definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey definition the
   *           survey instances are associated with
   *
   * @return the survey instances for all versions of the survey definition
   */
  List<SurveyInstance> getSurveyInstancesForSurveyDefinition(UUID id)
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
   * Retrieve the survey requests for the survey instance.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey instance the
   *           survey requests are associated with
   *
   * @return the survey requests for the survey instance
   */
  List<SurveyRequest> getSurveyRequestsForSurveyInstance(UUID id)
    throws SurveyServiceException;

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
   * Retrieve the survey responses for the survey instance.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey instance the
   *           survey responses are associated with
   *
   * @return the survey responses for the survey instance
   */
  List<SurveyResponse> getSurveyResponsesForSurveyInstance(UUID id)
    throws SurveyServiceException;

  /**
   * Save the survey audience.
   *
   * @param surveyAudience the survey audience
   *
   * @return the saved survey audience
   */
  SurveyAudience saveSurveyAudience(SurveyAudience surveyAudience)
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
   * Save the survey request.
   *
   * @param surveyRequest the survey request
   *
   * @return the saved survey request
   */
  SurveyRequest saveSurveyRequest(SurveyRequest surveyRequest)
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
