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
   * Delete the survey audience.
   *
   * @param surveyAudience the survey audience to delete
   *
   * @return <code>true</code> if the survey audience was deleted or <code>false</code> otherwise
   */
  boolean deleteSurveyAudience(SurveyAudience surveyAudience)
    throws SurveyServiceException;

  /**
   * Delete the survey audience with the specified ID.
   *
   * @param id  the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *            audience
   *
   * @return <code>true</code> if the survey audience was deleted or <code>false</code> otherwise
   */
  boolean deleteSurveyAudience(UUID id)
    throws SurveyServiceException;

  /**
   * Delete the survey audience member.
   *
   * @param surveyAudienceMember the survey audience member to delete
   *
   * @return <code>true</code> if the survey audience member was deleted or <code>false</code>
   *         otherwise
   */
  boolean deleteSurveyAudienceMember(SurveyAudienceMember surveyAudienceMember)
    throws SurveyServiceException;

  /**
   * Delete the survey audience member with the specified ID.
   *
   * @param id  the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *            audience member
   *
   * @return <code>true</code> if the survey audience member was deleted or <code>false</code>
   *         otherwise
   */
  boolean deleteSurveyAudienceMember(UUID id)
    throws SurveyServiceException;

  /**
   * Delete the survey definition.
   *
   * @param surveyDefinition the survey definition to delete
   *
   * @return <code>true</code> if the survey definition was deleted or <code>false</code> otherwise
   */
  boolean deleteSurveyDefinition(SurveyDefinition surveyDefinition)
    throws SurveyServiceException;

  /**
   * Delete all versions of the survey definition with the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to, along with the version of the
   *           survey definition, uniquely identify the survey definitions
   *
   * @return <code>true</code> if all versions of the survey definition were deleted or
   *        <code>false</code> otherwise
   */
  boolean deleteSurveyDefinition(UUID id)
    throws SurveyServiceException;

  /**
   * Delete the survey definition with the specified ID and version.
   *
   * @param id      the Universally Unique Identifier (UUID) used to, along with the version of the
   *                survey definition, uniquely identify the survey definition
   * @param version the version of the survey definition
   *
   * @return <code>true</code> if the survey definition was deleted or <code>false</code> otherwise
   */
  boolean deleteSurveyDefinition(UUID id, int version)
    throws SurveyServiceException;

  /**
   * Delete the survey instance.
   *
   * @param surveyInstance the survey instance to delete
   *
   * @return <code>true</code> if the survey instance was deleted or <code>false</code> otherwise
   */
  boolean deleteSurveyInstance(SurveyInstance surveyInstance)
    throws SurveyServiceException;

  /**
   * Delete the survey instance with the specified ID.
   *
   * @param id  the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *            instance
   *
   * @return <code>true</code> if the survey instance was deleted or <code>false</code> otherwise
   */
  boolean deleteSurveyInstance(UUID id)
    throws SurveyServiceException;

  /**
   * Delete the survey request.
   *
   * @param surveyRequest the survey request to delete
   *
   * @return <code>true</code> if the survey request was deleted or <code>false</code> otherwise
   */
  boolean deleteSurveyRequest(SurveyRequest surveyRequest)
    throws SurveyServiceException;

  /**
   * Delete the survey request with the specified ID.
   *
   * @param id  the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *            request
   *
   * @return <code>true</code> if the survey request was deleted or <code>false</code> otherwise
   */
  boolean deleteSurveyRequest(UUID id)
    throws SurveyServiceException;

  /**
   * Delete the survey response.
   *
   * @param surveyResponse the survey response to delete
   *
   * @return <code>true</code> if the survey response was deleted or <code>false</code> otherwise
   */
  boolean deleteSurveyResponse(SurveyResponse surveyResponse)
    throws SurveyServiceException;

  /**
   * Delete the survey response with the specified ID.
   *
   * @param id  the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *            response
   *
   * @return <code>true</code> if the survey response was deleted or <code>false</code> otherwise
   */
  boolean deleteSurveyResponse(UUID id)
    throws SurveyServiceException;

  /**
   * Delete the survey response for the survey request with the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey request
   *
   * @return <code>true</code> if the survey response was deleted successfully or <code>false</code>
   *         otherwise
   *
   * @throws SurveyServiceException
   */
  boolean deleteSurveyResponseForSurveyRequest(UUID id)
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
   * Retrieve the summaries for the latest versions of the filtered survey definitions for the
   * organisation.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the
   *               organisation
   * @param filter the filter used to limit the matching survey definitions
   *
   * @return the summaries for the latest versions of the filtered survey definitions for the
   *         organisation
   */
  List<SurveyDefinitionSummary> getFilteredSurveyDefinitionSummariesForOrganisation(UUID id,
      String filter)
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
   * Retrieve the summaries for the filtered survey responses for the survey instance.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey instance
   *               the survey responses are associated with
   * @param filter the filter used to limit the matching survey responses
   *
   * @return the summaries for the filtered survey responses for the survey instance
   */
  List<SurveyResponseSummary> getFilteredSurveyResponseSummariesForSurveyInstance(UUID id,
      String filter)
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
   * Retrieve the latest version of the survey definition identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to, along with the version of the
   *           survey definition, uniquely identify the survey definition
   *
   * @return the latest version of the survey definition identified by the specified ID
   */
  SurveyDefinition getLatestVersionOfSurveyDefinition(UUID id)
    throws SurveyServiceException;

  /**
   * Returns the maximum number of times that sending of a survey request will be attempted.
   *
   * @return the maximum number of times that sending of a survey request will be attempted
   */
  int getMaximumSurveyRequestSendAttempts()
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
   * Retrieve the next survey request that has been queued for sending.
   * <p/>
   * The survey request will be locked to prevent duplicate sending.
   *
   * @return the next survey request that has been queued for sending or <code>null</code> if no
   *         survey requests are currently queued for sending
   */
  SurveyRequest getNextSurveyRequestQueuedForSending()
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
   * Retrieve the number of filtered survey definitions for the organisation.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the
   *               organisation
   * @param filter the filter used to limit the matching survey definitions
   *
   * @return the number of filtered survey definitions for the organisation
   */
  int getNumberOfFilteredSurveyDefinitionsForOrganisation(UUID id, String filter)
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
   * Retrieve the number of survey definitions for the organisation.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the organisation
   *
   * @return the number of survey definitions for the organisation
   */
  int getNumberOfSurveyDefinitionsForOrganisation(UUID id)
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
   * Retrieve the survey request to survey response mappings for the survey instance.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey instance the
   *           survey requests and survey responses are associated with
   *
   * @return the the survey request to survey response mappings for the survey instance
   */
  List<SurveyRequestToSurveyResponseMapping> getRequestToResponseMappingsForSurveyInstance(UUID id)
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
   * @param id      the Universally Unique Identifier (UUID) used to, along with the version of the
   *                survey definition, uniquely identify the survey definition
   * @param version the version of the survey definition
   *
   * @return the survey definition identified by the specified ID and version or <code>null</code>
   *         if the survey definition could not be found
   */
  SurveyDefinition getSurveyDefinition(UUID id, int version)
    throws SurveyServiceException;

  /**
   * Retrieve the summaries for the latest versions of the survey definitions for the organisation.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the organisation
   *
   * @return the summaries for the latest versions of the survey definitions for the organisation
   */
  List<SurveyDefinitionSummary> getSurveyDefinitionSummariesForOrganisation(UUID id)
    throws SurveyServiceException;

  /**
   * Retrieve the summary for the survey definition identified by the specified ID and version.
   *
   * @param id      the Universally Unique Identifier (UUID) used to, along with the version of the
   *                survey definition, uniquely identify the survey definition
   * @param version the version of the survey definition
   *
   * @return the summary for the survey definition identified by the specified ID and version or
   *         <code>null</code> if the survey definition could not be found
   */
  SurveyDefinitionSummary getSurveyDefinitionSummary(UUID id, int version)
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
   * Retrieve the survey request with the specified e-mail address for the survey instance with
   * the specified ID.
   *
   * @param id    the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *              instance that the survey request is associated with
   * @param email the e-mail address
   *
   * @return the survey request with the specified e-mail address for the survey instance with
   *         the specified ID or <code>null</code> if no matching service request could be found
   */
  SurveyRequest getSurveyRequestForSurveyInstanceByEmail(UUID id, String email)
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
   * Retrieve the survey response associated with the survey request with the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           request the survey response is associated with
   *
   * @return the survey response associated with the survey request or <code>nul</code> if an
   *         associated survey response could not be found
   */
  SurveyResponse getSurveyResponseForSurveyRequest(UUID id)
    throws SurveyServiceException;

  /**
   * Retrieve the summaries for the survey responses for the survey instance.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey instance the
   *           survey responses are associated with
   *
   * @return the summaries for the survey responses for the survey instance
   */
  List<SurveyResponseSummary> getSurveyResponseSummariesForSurveyInstance(UUID id)
    throws SurveyServiceException;

  /**
   * Retrieve the summary for the survey response identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           response
   *
   * @return the summary for the survey response identified by the specified ID or <code>null</code>
   *         if the survey response could not be found
   */
  SurveyResponseSummary getSurveyResponseSummary(UUID id)
    throws SurveyServiceException;

  /**
   * Retrieve the the survey responses for the survey instance.
   *
   * NOTE: This is potentially a resource intensive operation if there are a large number of survey
   *       responses associated with a survey instance.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey instance the
   *           survey responses are associated with
   *
   * @return the survey responses for the survey instance
   */
  List<SurveyResponse> getSurveyResponsesForSurveyInstance(UUID id)
    throws SurveyServiceException;

  /**
   * Retrieve the survey result for the survey instance with the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           instance
   *
   * @return the survey result for the survey instance with the specified ID
   *
   * @throws SurveyServiceException
   */
  SurveyResult getSurveyResultForSurveyInstance(UUID id)
    throws SurveyServiceException;

  /**
   * Increment the send attempts for the survey request.
   *
   * @param surveyRequest the survey request
   *
   * @throws SurveyServiceException
   */
  void incrementSurveyRequestSendAttempts(SurveyRequest surveyRequest)
    throws SurveyServiceException;

  /**
   * Reset the survey request locks.
   *
   * @param status    the current status of the survey requests that have been locked
   * @param newStatus the new status for the survey requests that have been unlocked
   */
  void resetSurveyRequestLocks(SurveyRequestStatus status, SurveyRequestStatus newStatus)
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
   * Save the survey audience member.
   *
   * @param surveyAudienceMember the survey audience member
   *
   * @return the saved survey response
   */
  SurveyAudienceMember saveSurveyAudienceMember(SurveyAudienceMember surveyAudienceMember)
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

  /**
   * Send the survey request.
   *
   * @param surveyRequest the survey request to send
   *
   * @return <code>true</code> if the survey request was sent successfully or <code>false</code>
   *         otherwise
   */
  boolean sendSurveyRequest(SurveyRequest surveyRequest)
    throws SurveyServiceException;

  /**
   * Send a survey request, for the survey instance with the specified ID, to all survey audience
   * members for the survey audience.
   *
   * @param surveyInstanceId the Universally Unique Identifier (UUID) used to uniquely identify the
   *                         survey instance that the survey requests should be sent for
   * @param audience         the survey audience
   */
  void sendSurveyRequestToAudience(UUID surveyInstanceId, SurveyAudience audience)
    throws SurveyServiceException;

  /**
   * Send a survey request, for the survey instance with the specified ID, to the person with the
   * specified details.
   *
   * @param surveyInstanceId the Universally Unique Identifier (UUID) used to uniquely identify the
   *                         survey instance that the survey request should be sent for
   * @param firstName        the first name(s) for the person that will be sent the survey request
   * @param lastName         the last name for the person that will be sent the survey request
   * @param email            the e-mail address for the person who will be sent the survey request
   */
  void sendSurveyRequestToPerson(UUID surveyInstanceId, String firstName, String lastName,
      String email)
    throws SurveyServiceException;

  /**
   * Send all the survey requests queued for sending asynchronously.
   */
  void sendSurveyRequests();

  /**
   * Unlock the survey request.
   *
   * @param id     the Universally Unique Identifier (UUID) used to identify the survey request
   * @param status the new status for the unlocked survey request
   */
  void unlockSurveyRequest(UUID id, SurveyRequestStatus status)
    throws SurveyServiceException;
}
