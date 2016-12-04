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

package digital.survey.tests;

//~--- non-JDK imports --------------------------------------------------------

import digital.survey.model.*;
import guru.mmp.application.security.ISecurityService;
import guru.mmp.application.security.Organisation;
import guru.mmp.application.security.OrganisationStatus;
import guru.mmp.application.test.ApplicationClassRunner;
import guru.mmp.application.test.ApplicationDataSourceSQLResource;
import org.junit.Test;
import org.junit.runner.RunWith;

import javax.inject.Inject;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyServiceTest</code> class contains the implementation of the JUnit
 * tests for the <code>SurveyService</code> class.
 *
 * @author Marcus Portmann
 */
@RunWith(ApplicationClassRunner.class)
@ApplicationDataSourceSQLResource(path = "digital/survey/persistence/SurveyH2.sql")
public class SurveyServiceTest
{
  @Inject
  private ISurveyService surveyService;
  @Inject
  private ISecurityService securityService;

  // TODO ADD METHODS TO TEST BOTH TYPES OF DELETE

  /**
   * Test the get CTO values survey definition functionality.
   */
  @Test
  public void getCTOValuesSurveyDefinitionTest()
    throws Exception
  {
    SurveyDefinition surveyDefinition = getCTOValuesSurveyDefinitionDetails();

    System.out.println("Survey Definition: " + surveyDefinition.getData());

    System.out.println("\n");

    System.out.printf(
        "INSERT INTO SURVEY.SURVEY_DEFINITIONS (ID, VERSION, ORGANISATION_ID, NAME, DESCRIPTION, ANONYMOUS, DATA) VALUES ('%s', %d, '%s', '%s', '%s', FALSE, '%s');%n",
        surveyDefinition.getId(), surveyDefinition.getVersion(), surveyDefinition.getOrganisation()
        .getId(), surveyDefinition.getName(), surveyDefinition.getDescription(),
        surveyDefinition.getData());

    System.out.println();

    SurveyInstance surveyInstance = new SurveyInstance(UUID.fromString(
        "b222aa15-715f-4752-923d-8f33ee8a1736"), "CTO ELT Values - September 2016",
        "CTO ELT Values - September 2016", surveyDefinition);

    System.out.printf(
        "INSERT INTO SURVEY.SURVEY_INSTANCES(ID, SURVEY_DEFINITION_ID, SURVEY_DEFINITION_VERSION, NAME, DESCRIPTION) VALUES ('%s', '%s', %d, '%s', '%s');%n",
        surveyInstance.getId(), surveyInstance.getDefinition().getId(),
        surveyInstance.getDefinition().getVersion(), surveyInstance.getName(),
        surveyInstance.getDescription());

    System.out.println();

    for (int i = 0; i < 5; i++)
    {
      SurveyRequest testUserRequest = new SurveyRequest(UUID.randomUUID(), surveyInstance,
          "Test First Name " + i, "Test Last Name " + i, "test" + i + "@mmp.guru");

      SurveyResponse testUserResponse = new SurveyResponse(UUID.randomUUID(), surveyInstance,
          testUserRequest);

      randomizeSurveyResponse(testUserResponse);

      System.out.printf(
          "INSERT INTO SURVEY.SURVEY_REQUESTS(ID, SURVEY_INSTANCE_ID, FIRST_NAME, LAST_NAME, EMAIL, REQUESTED, STATUS) VALUES\n ('%s', '%s', '%s', '%s', '%s', NOW(), 3);%n",
          testUserRequest.getId(), testUserRequest.getInstance().getId(),
          testUserRequest.getFirstName(), testUserRequest.getLastName(),
          testUserRequest.getEmail());

      System.out.printf(
          "INSERT INTO SURVEY.SURVEY_RESPONSES (ID, SURVEY_INSTANCE_ID, SURVEY_REQUEST_ID, RESPONDED, DATA) VALUES\n ('%s', '%s', '%s', NOW(), '%s');%n",
          testUserResponse.getId(), testUserResponse.getInstance().getId(),
          testUserRequest.getId(), testUserResponse.getData());

      System.out.println();

    }

//  SurveyRequest marcusSurveyRequest = new SurveyRequest(UUID.fromString(
//      "54a751f6-0f32-48bd-8c6c-665e3ac1906b"), surveyInstance, "Marcus", "Portmann",
//      "marcus@mmp.guru");
//
//  SurveyResponse marcusSurveyResponse = new SurveyResponse(UUID.fromString(
//      "18f3fcc1-06b2-4dc4-90ea-7a8904009488"), surveyInstance, marcusSurveyRequest);
//
//  randomizeSurveyResponse(marcusSurveyResponse);
//
//  SurveyRequest aidenSurveyRequest = new SurveyRequest(UUID.fromString(
//      "215640fd-ee60-4f66-82bc-d173955b2228"), surveyInstance, "Aiden", "Portmann",
//      "aiden@mmp.guru");
//
//  SurveyResponse aidenSurveyResponse = new SurveyResponse(UUID.fromString(
//      "f2aab238-9d79-4272-bd3e-0085f2f86a9a"), surveyInstance, aidenSurveyRequest);
//
//  randomizeSurveyResponse(aidenSurveyResponse);

    // System.out.println("Survey Response (Marcus Portmann): " + marcusSurveyResponse.getData());

    // System.out.println("Survey Response (Aiden Portmann): " + aidenSurveyResponse.getData());

//  System.out.printf(
//      "INSERT INTO SURVEY.SURVEY_REQUESTS(ID, SURVEY_INSTANCE_ID, FIRST_NAME, LAST_NAME, EMAIL, REQUESTED, STATUS) VALUES\n ('%s', '%s', '%s', '%s', '%s', NOW(), 3);%n",
//      marcusSurveyRequest.getId(), marcusSurveyRequest.getInstance().getId(),
//      marcusSurveyRequest.getFirstName(), marcusSurveyRequest.getLastName(),
//      marcusSurveyRequest.getEmail());
//  System.out.printf(
//    "INSERT INTO SURVEY.SURVEY_REQUESTS(ID, SURVEY_INSTANCE_ID, FIRST_NAME, LAST_NAME, EMAIL, REQUESTED, STATUS) VALUES\n ('%s', '%s', '%s', '%s', '%s', NOW(), 3);%n",
//    aidenSurveyRequest.getId(), aidenSurveyRequest.getInstance().getId(),
//    aidenSurveyRequest.getFirstName(), aidenSurveyRequest.getLastName(),
//    aidenSurveyRequest.getEmail());
//
//  System.out.println();
//
//  System.out.printf(
//    "INSERT INTO SURVEY.SURVEY_RESPONSES (ID, SURVEY_INSTANCE_ID, SURVEY_REQUEST_ID, RESPONDED, DATA) VALUES\n ('%s', '%s', '%s', NOW(), '%s');%n",
//    marcusSurveyResponse.getId(), marcusSurveyResponse.getInstance().getId(),
//    marcusSurveyRequest.getId(), marcusSurveyResponse.getData());
//
//  System.out.printf(
//    "INSERT INTO SURVEY.SURVEY_RESPONSES (ID, SURVEY_INSTANCE_ID, SURVEY_REQUEST_ID, RESPONDED, DATA) VALUES\n ('%s', '%s', '%s', NOW(), '%s');%n",
//    aidenSurveyResponse.getId(), aidenSurveyResponse.getInstance().getId(),
//    aidenSurveyRequest.getId(), aidenSurveyResponse.getData());

    System.out.println();
    System.out.println();

  }

  /**
   * Test the remove survey group definition member functionality.
   */
  @Test
  public void removeSurveyGroupDefinitionMemberTest()
    throws Exception
  {
    Organisation organisation = getTestOrganisationDetails();

    securityService.createOrganisation(organisation, true);

    SurveyDefinition surveyDefinition = getTestSurveyDefinitionDetails(organisation);

    surveyDefinition = surveyService.saveSurveyDefinition(surveyDefinition);

    surveyDefinition = surveyService.getSurveyDefinition(surveyDefinition.getId(), 1);

    SurveyGroupDefinition firstSurveyGroupDefinition = surveyDefinition.getGroupDefinitions()
        .iterator().next();

    firstSurveyGroupDefinition.removeGroupMemberDefinition(
        firstSurveyGroupDefinition.getGroupMemberDefinitions().get(0).getId());

    surveyService.saveSurveyDefinition(surveyDefinition);

    SurveyDefinition retrievedSurveyDefinition = surveyService.getSurveyDefinition(
        surveyDefinition.getId(), surveyDefinition.getVersion());

    compareSurveyDefinitions(surveyDefinition, retrievedSurveyDefinition);

    surveyService.deleteSurveyDefinition(surveyDefinition.getId());
  }

  /**
   * Test the remove survey group definition functionality.
   */
  @Test
  public void removeSurveyGroupDefinitionTest()
    throws Exception
  {
    Organisation organisation = getTestOrganisationDetails();

    securityService.createOrganisation(organisation, true);

    SurveyDefinition surveyDefinition = getTestSurveyDefinitionDetails(organisation);

    surveyDefinition = surveyService.saveSurveyDefinition(surveyDefinition);

    surveyDefinition = surveyService.getSurveyDefinition(surveyDefinition.getId(), 1);

    SurveyGroupDefinition firstSurveyGroupDefinition = surveyDefinition.getGroupDefinitions()
        .iterator().next();

    surveyDefinition.removeGroupDefinition(firstSurveyGroupDefinition.getId());

    surveyService.saveSurveyDefinition(surveyDefinition);

    SurveyDefinition retrievedSurveyDefinition = surveyService.getSurveyDefinition(
        surveyDefinition.getId(), surveyDefinition.getVersion());

    compareSurveyDefinitions(surveyDefinition, retrievedSurveyDefinition);

    surveyService.deleteSurveyDefinition(surveyDefinition.getId());
  }

  /**
   * Test the remove survey group ratings definition functionality.
   */
  @Test
  public void removeSurveyGroupRatingsDefinition()
    throws Exception
  {
    Organisation organisation = getTestOrganisationDetails();

    securityService.createOrganisation(organisation, true);

    SurveyDefinition surveyDefinition = getTestSurveyDefinitionDetails(organisation);

    surveyDefinition = surveyService.saveSurveyDefinition(surveyDefinition);

    surveyDefinition = surveyService.getSurveyDefinition(surveyDefinition.getId(), 1);

    surveyDefinition.getItemDefinitions().remove(surveyDefinition.getItemDefinitions().iterator()
        .next());

    surveyService.saveSurveyDefinition(surveyDefinition);

    SurveyDefinition retrievedSurveyDefinition = surveyService.getSurveyDefinition(
        surveyDefinition.getId(), surveyDefinition.getVersion());

    compareSurveyDefinitions(surveyDefinition, retrievedSurveyDefinition);

    surveyService.deleteSurveyDefinition(surveyDefinition.getId());

    // TODO: Add test for removing a survey group ratings definition from a survey section
  }

  /**
   * Test the save CTO Values survey response functionality.
   */
  @Test
  public void saveCTOValuesSurveyResponseTest()
    throws Exception
  {
    SurveyDefinition surveyDefinition = getCTOValuesSurveyDefinitionDetails();

    surveyDefinition = surveyService.saveSurveyDefinition(surveyDefinition);

    SurveyInstance surveyInstance = getCTOValuesSurveyInstanceDetails(surveyDefinition);

    surveyInstance = surveyService.saveSurveyInstance(surveyInstance);

    SurveyResponse surveyResponse = new SurveyResponse(surveyInstance);

    surveyResponse = surveyService.saveSurveyResponse(surveyResponse);

    SurveyResponse retrievedSurveyResponse = surveyService.getSurveyResponse(
        surveyResponse.getId());

    compareSurveyResponses(surveyResponse, retrievedSurveyResponse);

    surveyService.deleteSurveyResponse(surveyResponse);

    surveyService.deleteSurveyInstance(surveyInstance);

    surveyService.deleteSurveyDefinition(surveyDefinition.getId());
  }

  /**
   * Test the save new survey definition functionality.
   */
  @Test
  public void saveNewSurveyDefinitionTest()
    throws Exception
  {
    Organisation organisation = getTestOrganisationDetails();

    securityService.createOrganisation(organisation, true);

    SurveyDefinition surveyDefinition = getTestSurveyDefinitionDetails(organisation);

    surveyDefinition = surveyService.saveSurveyDefinition(surveyDefinition);

    SurveyDefinition retrievedSurveyDefinition = surveyService.getSurveyDefinition(
        surveyDefinition.getId(), 1);

    compareSurveyDefinitions(surveyDefinition, retrievedSurveyDefinition);

    surveyService.deleteSurveyDefinition(surveyDefinition.getId());
  }

  /**
   * Test the save new survey definition version functionality.
   */
  @Test
  public void saveNewSurveyDefinitionVersionTest()
    throws Exception
  {
    Organisation organisation = getTestOrganisationDetails();

    securityService.createOrganisation(organisation, true);

    SurveyDefinition surveyDefinition = getTestSurveyDefinitionDetails(organisation);

    SurveyDefinition savedSurveyDefinition = surveyService.saveSurveyDefinition(surveyDefinition);

    compareSurveyDefinitions(surveyDefinition, savedSurveyDefinition);

    SurveyInstance surveyInstance = getTestSurveyInstanceDetails(surveyDefinition);

    surveyInstance = surveyService.saveSurveyInstance(surveyInstance);

    SurveyInstance retrievedSurveyInstance = surveyService.getSurveyInstance(
        surveyInstance.getId());

    compareSurveyInstances(surveyInstance, retrievedSurveyInstance);

    savedSurveyDefinition = surveyService.saveSurveyDefinition(savedSurveyDefinition);

    SurveyDefinition retrievedSurveyDefinition = surveyService.getSurveyDefinition(
        surveyDefinition.getId(), savedSurveyDefinition.getVersion());

    compareSurveyDefinitions(savedSurveyDefinition, retrievedSurveyDefinition);

    assertEquals("The version number for the updated survey definition is incorrect", 2,
        surveyService.getLatestVersionNumberForSurveyDefinition(surveyDefinition.getId()));

    retrievedSurveyDefinition = surveyService.getLatestVersionOfSurveyDefinition(
        surveyDefinition.getId());

    compareSurveyDefinitions(savedSurveyDefinition, retrievedSurveyDefinition);

    List<SurveyDefinitionSummary> retrievedSurveyDefinitionSummaries =
        surveyService.getSurveyDefinitionSummariesForOrganisation(organisation.getId());

    for (SurveyDefinitionSummary tmpSurveyDefinitionSummary : retrievedSurveyDefinitionSummaries)
    {
      if (tmpSurveyDefinitionSummary.getId().equals(surveyDefinition.getId()))
      {
        assertEquals("The ID for the survey definition summary is incorrect",
            savedSurveyDefinition.getId(), tmpSurveyDefinitionSummary.getId());
        assertEquals("The name for the survey definition summary is incorrect",
            savedSurveyDefinition.getName(), tmpSurveyDefinitionSummary.getName());
        assertEquals("The version for the survey definition summary is incorrect",
            savedSurveyDefinition.getVersion(), tmpSurveyDefinitionSummary.getVersion());
      }
    }

    assertEquals("The number of latest survey definitions for the organisation is incorrect",
        retrievedSurveyDefinitionSummaries.size(),
        surveyService.getNumberOfSurveyDefinitionsForOrganisation(organisation.getId()));

    assertEquals(
        "The number of filtered latest survey definitions for the organisation is incorrect", 1,
        surveyService.getNumberOfFilteredSurveyDefinitionsForOrganisation(organisation.getId(),
        surveyDefinition.getName()));

    retrievedSurveyDefinitionSummaries =
        surveyService.getFilteredSurveyDefinitionSummariesForOrganisation(organisation.getId(),
        surveyDefinition.getName());

    for (SurveyDefinitionSummary tmpSurveyDefinitionSummary : retrievedSurveyDefinitionSummaries)
    {
      if (tmpSurveyDefinitionSummary.getId().equals(surveyDefinition.getId()))
      {
        compareSurveyDefinitions(savedSurveyDefinition, tmpSurveyDefinitionSummary);
      }
    }

    SurveyDefinitionSummary surveyDefinitionSummary = surveyService.getSurveyDefinitionSummary(
        savedSurveyDefinition.getId(), savedSurveyDefinition.getVersion());

    compareSurveyDefinitions(savedSurveyDefinition, surveyDefinitionSummary);

    surveyService.deleteSurveyInstance(surveyInstance);

    surveyService.deleteSurveyDefinition(surveyDefinition.getId());
  }

  /**
   * Test the save updated survey definition functionality.
   */
  @Test
  public void saveUpdatedSurveyDefinitionTest()
    throws Exception
  {
    Organisation organisation = getTestOrganisationDetails();

    securityService.createOrganisation(organisation, true);

    SurveyDefinition surveyDefinition = getTestSurveyDefinitionDetails(organisation);

    surveyDefinition = surveyService.saveSurveyDefinition(surveyDefinition);

    surveyDefinition = surveyService.getSurveyDefinition(surveyDefinition.getId(), 1);

    surveyDefinition.setName(surveyDefinition.getName() + " Updated");
    surveyDefinition.setDescription(surveyDefinition.getDescription() + " Updated");

    surveyDefinition = surveyService.saveSurveyDefinition(surveyDefinition);

    SurveyDefinition retrievedSurveyDefinition = surveyService.getSurveyDefinition(
        surveyDefinition.getId(), surveyDefinition.getVersion());

    compareSurveyDefinitions(surveyDefinition, retrievedSurveyDefinition);

    surveyService.deleteSurveyDefinition(surveyDefinition.getId());
  }

  /**
   * Test the survey audience functionality.
   *
   */
  @Test
  public void surveyAudienceTest()
    throws Exception
  {
    Organisation organisation = getTestOrganisationDetails();

    securityService.createOrganisation(organisation, true);

    SurveyAudience surveyAudience = getTestSurveyAudienceDetails(organisation);

    surveyAudience = surveyService.saveSurveyAudience(surveyAudience);

    SurveyAudience retrievedSurveyAudience = surveyService.getSurveyAudience(
        surveyAudience.getId());

    compareSurveyAudiences(surveyAudience, retrievedSurveyAudience);

    List<SurveyAudienceMember> surveyAudienceMembers = getTestSurveyAudienceMembersDetails(
        surveyAudience);

    for (SurveyAudienceMember surveyAudienceMember : surveyAudienceMembers)
    {
      surveyService.saveSurveyAudienceMember(surveyAudienceMember);
    }

    assertEquals("Failed to retrieve the correct number of survey audiences for the organisation ("
        + organisation.getId() + ")", 1, surveyService.getNumberOfSurveyAudiencesForOrganisation(
        organisation.getId()));

    assertEquals(
        "Failed to retrieve the correct number of survey audience members for the survey audience ("
        + surveyAudience.getId() + ")", surveyAudienceMembers.size(),
        surveyService.getNumberOfMembersForSurveyAudience(surveyAudience.getId()));

    assertEquals(
        "Failed to retrieve the correct number of filtered survey audiences for the organisation ("
        + organisation.getId() + ")", 1,
        surveyService.getNumberOfFilteredSurveyAudiencesForOrganisation(organisation.getId(),
        "Test"));

    retrievedSurveyAudience = surveyService.getFilteredSurveyAudiencesForOrganisation(
        organisation.getId(), "Test").get(0);

    compareSurveyAudiences(surveyAudience, retrievedSurveyAudience);

    assertEquals(
        "Failed to retrieve the correct number of filtered survey audience members for the survey audience ("
        + surveyAudience.getId() + ")", 1,
        surveyService.getNumberOfFilteredMembersForSurveyAudience(surveyAudience.getId(),
        "Test First Name 1"));

    SurveyAudienceMember retrievedSurveyAudienceMember =
        surveyService.getFilteredMembersForSurveyAudience(surveyAudience.getId(),
        "Test First Name 1").get(0);

    compareSurveyAudienceMembers(surveyAudienceMembers.get(0), retrievedSurveyAudienceMember);

    SurveyAudienceMember surveyAudienceMember = new SurveyAudienceMember(UUID.randomUUID(),
        surveyAudience, "Another Test First Name", "Another Test Last Name", "Another Test E-mail");

    surveyService.saveSurveyAudienceMember(surveyAudienceMember);

    surveyService.deleteSurveyAudience(surveyAudience);
  }

  /**
   * Test the survey request functionality.
   */
  @Test
  public void surveyRequestTest()
    throws Exception
  {
    Organisation organisation = getTestOrganisationDetails();

    securityService.createOrganisation(organisation, true);

    SurveyDefinition surveyDefinition = getTestSurveyDefinitionDetails(organisation);

    surveyDefinition = surveyService.saveSurveyDefinition(surveyDefinition);

    SurveyInstance surveyInstance = getTestSurveyInstanceDetails(surveyDefinition);

    surveyInstance = surveyService.saveSurveyInstance(surveyInstance);

    SurveyRequest surveyRequest = getTestSurveyRequestDetails(surveyInstance);

    surveyRequest = surveyService.saveSurveyRequest(surveyRequest);

    SurveyRequest retrievedSurveyRequest = surveyService.getSurveyRequest(surveyRequest.getId());

    compareSurveyRequests(surveyRequest, retrievedSurveyRequest);

    assertEquals("The number of survey requests for the survey instance is not correct", 1,
        surveyService.getNumberOfSurveyRequestsForSurveyInstance(surveyInstance.getId()));

    List<SurveyRequest> surveyRequests = surveyService.getSurveyRequestsForSurveyInstance(
        surveyInstance.getId());

    assertEquals("The number of survey requests for the survey instance is not correct", 1,
        surveyRequests.size());

    compareSurveyRequests(surveyRequest, surveyRequests.get(0));

    assertEquals("The number of filtered survey requests for the survey instance is not correct",
        1, surveyService.getNumberOfFilteredSurveyRequestsForSurveyInstance(surveyInstance.getId(),
        "Marcus"));

    surveyRequests = surveyService.getFilteredSurveyRequestsForSurveyInstance(
        surveyInstance.getId(), "Marcus");

    assertEquals("The number of filtered survey requests for the survey instance is not correct",
        1, surveyRequests.size());

    compareSurveyRequests(surveyRequest, surveyRequests.get(0));

    surveyRequest.setRequested(new Date());
    surveyRequest.setLockName("LOCK NAME");
    surveyRequest.setLastProcessed(new Date());
    surveyRequest.setStatus(SurveyRequestStatus.FAILED);
    surveyRequest.setSendAttempts(666);

    surveyService.saveSurveyRequest(surveyRequest);

    retrievedSurveyRequest = surveyService.getSurveyRequest(surveyRequest.getId());

    compareSurveyRequests(surveyRequest, retrievedSurveyRequest);

    surveyService.deleteSurveyRequest(surveyRequest);

    surveyService.deleteSurveyInstance(surveyInstance);

    surveyService.deleteSurveyDefinition(surveyDefinition.getId());
  }

  /**
   * Test the survey response functionality.
   */
  @Test
  public void surveyResponseTest()
    throws Exception
  {
    Organisation organisation = getTestOrganisationDetails();

    securityService.createOrganisation(organisation, true);

    SurveyDefinition surveyDefinition = getTestSurveyDefinitionDetails(organisation);

    surveyDefinition = surveyService.saveSurveyDefinition(surveyDefinition);

    surveyDefinition = surveyService.getSurveyDefinition(surveyDefinition.getId(), 1);

    SurveyInstance surveyInstance = getTestSurveyInstanceDetails(surveyDefinition);

    surveyInstance = surveyService.saveSurveyInstance(surveyInstance);

    SurveyRequest surveyRequest = getTestSurveyRequestDetails(surveyInstance);

    surveyRequest = surveyService.saveSurveyRequest(surveyRequest);

    SurveyResponse surveyResponse = new SurveyResponse(surveyInstance, surveyRequest);

    surveyResponse = surveyService.saveSurveyResponse(surveyResponse);

    SurveyResponse retrievedSurveyResponse = surveyService.getSurveyResponse(
        surveyResponse.getId());

    compareSurveyResponses(surveyResponse, retrievedSurveyResponse);

    retrievedSurveyResponse = surveyService.getSurveyResponseForSurveyRequest(
        surveyRequest.getId());

    compareSurveyResponses(surveyResponse, retrievedSurveyResponse);

    assertEquals("The number of survey responses for the survey instance is not correct", 1,
        surveyService.getNumberOfSurveyResponsesForSurveyInstance(surveyInstance.getId()));

    List<SurveyResponseSummary> surveyResponseSummaries =
        surveyService.getSurveyResponseSummariesForSurveyInstance(surveyInstance.getId());

    assertEquals("The number of survey responses for the survey instance is not correct", 1,
        surveyResponseSummaries.size());

    compareSurveyResponses(surveyResponse, surveyResponseSummaries.get(0));

    List<SurveyRequestToSurveyResponseMapping> requestAndResponseIds =
        surveyService.getRequestToResponseMappingsForSurveyInstance(surveyInstance.getId());

    assertEquals("The number of request and response IDs for the survey instance is not correct",
        1, requestAndResponseIds.size());

    assertEquals(surveyResponse.getId(), requestAndResponseIds.get(0).getResponseId());

    assertEquals("The number of filtered survey responses for the survey instance is not correct",
        1, surveyService.getNumberOfFilteredSurveyResponsesForSurveyInstance(
        surveyInstance.getId(), "Marcus"));

    surveyResponseSummaries = surveyService.getFilteredSurveyResponseSummariesForSurveyInstance(
        surveyInstance.getId(), "Marcus");

    assertEquals("The number of filtered survey responses for the survey instance is not correct",
        1, surveyResponseSummaries.size());

    compareSurveyResponses(surveyResponse, surveyResponseSummaries.get(0));

    SurveyResponseSummary surveyResponseSummary = surveyService.getSurveyResponseSummary(
        surveyResponse.getId());

    compareSurveyResponses(surveyResponse, surveyResponseSummary);

    surveyService.deleteSurveyResponse(surveyResponse);

    assertEquals("The survey response was not deleted", null, surveyService.getSurveyResponse(
        surveyResponse.getId()));

    surveyService.deleteSurveyRequest(surveyRequest);

    assertEquals("The survey request was not deleted", null, surveyService.getSurveyRequest(
        surveyRequest.getId()));

    surveyService.deleteSurveyInstance(surveyInstance);

    assertEquals("The survey instance was not deleted", null, surveyService.getSurveyInstance(
        surveyInstance.getId()));

    surveyService.deleteSurveyDefinition(surveyDefinition.getId());

    assertEquals("The survey definition was not deleted", null, surveyService.getSurveyDefinition(
        surveyDefinition.getId(), surveyDefinition.getVersion()));
  }

  private static synchronized SurveyDefinition getCTOValuesSurveyDefinitionDetails()
  {
    Organisation organisation = new Organisation(UUID.fromString(
        "d077425e-c75f-4dd8-9d62-81f2d26b8a62"), "BAGL - Africa Technology - CTO",
        OrganisationStatus.ACTIVE);

    SurveyDefinition surveyDefinition = new SurveyDefinition(UUID.fromString(
        "706fb4a4-8ba8-11e6-ae22-56b6b6499611"), 1, organisation, "CTO ELT Values",
        "CTO ELT Values");

    SurveyGroupDefinition surveyGroupDefinition = new SurveyGroupDefinition(UUID.fromString(
        "d3cf5bf2-9226-429f-bbbf-126a298e0e57"), "CTO ELT", "CTO ELT");

    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.fromString(
        "1dc16425-638b-43ec-82be-7fe2427836e2"), "CTO ELT"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.fromString(
        "57be5b5e-950e-494f-b0a1-51637c062c5c"), "Peter"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.fromString(
        "84327d2d-b0d4-4cad-9a00-f2f9c33d1fb6"), "Adriaan"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.fromString(
        "cd5297cf-7fc6-4b9d-a9dc-6bea68d191a1"), "Alapan"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.fromString(
        "0e73d1cd-38fa-452b-9490-dac101c04174"), "Dan"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.fromString(
        "4b6b3950-c15d-491a-92b9-1c4e8000cbb9"), "Daryl"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.fromString(
        "4bde7d66-afc3-4445-a227-9b5d8d532ae0"), "David"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.fromString(
        "3129ac0d-1a34-4221-a1ad-a01b51bfcad8"), "Francois"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.fromString(
        "a704eea9-3f8b-4095-87bb-fd0407c9f309"), "James"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.fromString(
        "eb90097c-eb8b-411f-ace2-f14e2937d83f"), "Kersh"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.fromString(
        "e4189470-9449-40d9-8952-c468c1e96aa6"), "Kevin"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.fromString(
        "1c124329-d138-40ce-b1b9-259f51c12705"), "Linde-Marie"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.fromString(
        "35efdc8c-e855-4b68-839f-95b00d025c7a"), "Manoj"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.fromString(
        "2f6008ce-b3bc-47da-bb37-2d18063fe910"), "Marcus"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.fromString(
        "fd4a21ba-3870-4521-9831-76ddcded3675"), "Mercia"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.fromString(
        "c83167da-b806-437d-828a-ee786260243b"), "Nicole"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.fromString(
        "9503ff85-efa5-451d-a48b-02a3491eeebc"), "Lawrence"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.fromString(
        "4a6d677b-b58f-4db3-9802-c5358a150fc4"), "Richard"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.fromString(
        "8e094c16-58b1-4707-bf5e-2cf11426d046"), "Sandra"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.fromString(
        "4ab33e8e-df64-4b79-a46d-c0f9b6ed7a3c"), "Tendai"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.fromString(
        "d7681710-e3ab-4716-a5ad-864b5f3a3e4c"), "Debbie"));

    surveyDefinition.addGroupDefinition(surveyGroupDefinition);

    SurveyGroupRatingsDefinition surveyGroupRatingsDefinition = new SurveyGroupRatingsDefinition(
        UUID.fromString("d7a16b81-d2a2-4f07-aa56-4846af42eea9"), "cto_values", "CTO Values",
        "CTO Values", surveyGroupDefinition.getId(), true);

    surveyGroupRatingsDefinition.addGroupRatingDefinition(new SurveyGroupRatingDefinition(
        UUID.fromString("7e5a49ad-1b36-4fb9-9d5d-a639d12b4505"), "Accountability",
        SurveyGroupRatingType.YES_NO_NA));
    surveyGroupRatingsDefinition.addGroupRatingDefinition(new SurveyGroupRatingDefinition(
        UUID.fromString("b4450b10-c88b-4b62-9a31-98a64880a96a"), "Competence", SurveyGroupRatingType
        .YES_NO_NA));
    surveyGroupRatingsDefinition.addGroupRatingDefinition(new SurveyGroupRatingDefinition(
        UUID.fromString("91e05612-d464-4689-8af3-4cf225782f8a"), "Courage", SurveyGroupRatingType
        .YES_NO_NA));
    surveyGroupRatingsDefinition.addGroupRatingDefinition(new SurveyGroupRatingDefinition(
        UUID.fromString("6cde6e39-aaf8-4f96-9952-d487d2584be7"), "Fairness", SurveyGroupRatingType
        .YES_NO_NA));
    surveyGroupRatingsDefinition.addGroupRatingDefinition(new SurveyGroupRatingDefinition(
        UUID.fromString("a603e933-913c-4976-8c33-84ecee181648"), "Integrity", SurveyGroupRatingType
        .YES_NO_NA));
    surveyGroupRatingsDefinition.addGroupRatingDefinition(new SurveyGroupRatingDefinition(
        UUID.fromString("32a851c4-c64c-4873-8ed8-f81e277b470a"), "Openness", SurveyGroupRatingType
        .YES_NO_NA));
    surveyGroupRatingsDefinition.addGroupRatingDefinition(new SurveyGroupRatingDefinition(
        UUID.fromString("db7abbb0-002f-446a-b3ef-505783040790"), "Positive Attitude",
        SurveyGroupRatingType.YES_NO_NA));
    surveyGroupRatingsDefinition.addGroupRatingDefinition(new SurveyGroupRatingDefinition(
        UUID.randomUUID(), "Teamwork", SurveyGroupRatingType.YES_NO_NA));
    surveyGroupRatingsDefinition.addGroupRatingDefinition(new SurveyGroupRatingDefinition(
        UUID.fromString("c34977a9-b1e5-4b1c-80e5-bbebf11de725"), "Making a difference",
        SurveyGroupRatingType.YES_NO_NA));
    surveyGroupRatingsDefinition.addGroupRatingDefinition(new SurveyGroupRatingDefinition(
        UUID.fromString("0dbf6e27-386a-4f3c-aefe-9aec39941efd"), "Trust", SurveyGroupRatingType
        .YES_NO_NA));

    surveyDefinition.addItemDefinition(surveyGroupRatingsDefinition);

    return surveyDefinition;
  }

  private static synchronized SurveyInstance getCTOValuesSurveyInstanceDetails(
      SurveyDefinition surveyDefinition)
  {
    return new SurveyInstance(UUID.randomUUID(), "CTO ELT Values - September 2016",
        "CTO ELT Values - September 2016", surveyDefinition);
  }

  private static synchronized Organisation getTestOrganisationDetails()
  {
    UUID id = UUID.randomUUID();

    return new Organisation(id, "Test Organisation (" + id + ")", OrganisationStatus.ACTIVE);
  }

  private static synchronized SurveyAudience getTestSurveyAudienceDetails(Organisation organisation)
  {
    return new SurveyAudience(UUID.randomUUID(), organisation, "Test Survey Audience", "");
  }

  private static synchronized List<SurveyAudienceMember> getTestSurveyAudienceMembersDetails(
      SurveyAudience surveyAudience)
  {
    List<SurveyAudienceMember> surveyAudienceMembers = new ArrayList<>();

    surveyAudienceMembers.add(new SurveyAudienceMember(UUID.randomUUID(), surveyAudience,
        "Test First Name 1", "Test Last Name 1", "Test Email 1"));
    surveyAudienceMembers.add(new SurveyAudienceMember(UUID.randomUUID(), surveyAudience,
        "Test First Name 2", "Test Last Name 2", "Test Email 2"));
    surveyAudienceMembers.add(new SurveyAudienceMember(UUID.randomUUID(), surveyAudience,
        "Test First Name 3", "Test Last Name 3", "Test Email 3"));

    return surveyAudienceMembers;
  }

  private static synchronized SurveyDefinition getTestSurveyDefinitionDetails(
      Organisation organisation)
  {
    SurveyDefinition surveyDefinition = new SurveyDefinition(UUID.randomUUID(), 1, organisation,
        "Test Survey Definition Name", "Test Survey Definition Description");

    SurveySectionDefinition surveySectionDefinition1 = new SurveySectionDefinition(
        UUID.randomUUID(), "test_survey_section_definition_1",
        "Test Survey Section Definition Name 1", "Test Survey Section Definition Description 1");
    SurveySectionDefinition surveySectionDefinition2 = new SurveySectionDefinition(
        UUID.randomUUID(), "test_survey_section_definition_2",
        "Test Survey Section Definition Name 2", "Test Survey Section Definition Description 2");
    SurveySectionDefinition surveySectionDefinition3 = new SurveySectionDefinition(
        UUID.randomUUID(), "test_survey_section_definition_3",
        "Test Survey Section Definition Name 3", "Test Survey Section Definition Description 3");

    surveyDefinition.addItemDefinition(surveySectionDefinition1);
    surveyDefinition.addItemDefinition(surveySectionDefinition2);
    surveyDefinition.addItemDefinition(surveySectionDefinition3);

    SurveyGroupDefinition surveyGroupDefinition = new SurveyGroupDefinition(UUID.randomUUID(),
        "Test Survey Group Definition Name", "Test Survey Group Definition Description");

    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Test Survey Group Member Definition Name 1"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Test Survey Group Member Definition Name 2"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Test Survey Group Member Definition Name 4"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Test Survey Group Member Definition Name 3"));

    surveyDefinition.addGroupDefinition(surveyGroupDefinition);

    SurveyGroupRatingsDefinition surveyGroupRatingsDefinition = new SurveyGroupRatingsDefinition(
        UUID.randomUUID(), "test_survey_group_ratings_definition",
        "Test Survey Group Ratings Definition", "Test Survey Group Ratings Definition",
        surveyGroupDefinition.getId(), true);

    surveyGroupRatingsDefinition.addGroupRatingDefinition(new SurveyGroupRatingDefinition(
        UUID.randomUUID(), "Test Survey Group Rating Definition 1", SurveyGroupRatingType
        .YES_NO_NA));
    surveyGroupRatingsDefinition.addGroupRatingDefinition(new SurveyGroupRatingDefinition(
        UUID.randomUUID(), "Test Survey Group Rating Definition 2", SurveyGroupRatingType
        .YES_NO_NA));
    surveyGroupRatingsDefinition.addGroupRatingDefinition(new SurveyGroupRatingDefinition(
        UUID.randomUUID(), "Test Survey Group Rating Definition 3", SurveyGroupRatingType
        .YES_NO_NA));

    surveyDefinition.addItemDefinition(surveyGroupRatingsDefinition);

    SurveyGroupRatingsDefinition surveyNestedGroupRatingsDefinition1 =
        new SurveyGroupRatingsDefinition(UUID.randomUUID(),
        "test_nested_survey_group_ratings_definition_1",
        "Test Nested Survey Group Ratings Definition 1",
        "Test Nested Survey Group Ratings Definition 1", surveyGroupDefinition.getId(), true);

    SurveyGroupRatingsDefinition surveyNestedGroupRatingsDefinition2 =
        new SurveyGroupRatingsDefinition(UUID.randomUUID(),
        "test_nested_survey_group_ratings_definition_2",
        "Test Nested Survey Group Ratings Definition 2",
        "Test Nested Survey Group Ratings Definition 2", surveyGroupDefinition.getId(), true);

    SurveyGroupRatingsDefinition surveyNestedGroupRatingsDefinition3 =
        new SurveyGroupRatingsDefinition(UUID.randomUUID(),
        "test_nested_survey_group_ratings_definition_3",
        "Test Nested Survey Group Ratings Definition 3",
        "Test Nested Survey Group Ratings Definition 3", surveyGroupDefinition.getId(), true);

    surveyNestedGroupRatingsDefinition1.addGroupRatingDefinition(new SurveyGroupRatingDefinition(
        UUID.randomUUID(), "Test Nested Survey Group Definition Rating Item 1",
        SurveyGroupRatingType.YES_NO_NA));

    surveySectionDefinition1.addItemDefinition(surveyNestedGroupRatingsDefinition1);

    surveyNestedGroupRatingsDefinition2.addGroupRatingDefinition(new SurveyGroupRatingDefinition(
        UUID.randomUUID(), "Test Nested Survey Group Definition Rating Item 2",
        SurveyGroupRatingType.YES_NO_NA));

    surveySectionDefinition2.addItemDefinition(surveyNestedGroupRatingsDefinition2);

    surveyNestedGroupRatingsDefinition3.addGroupRatingDefinition(new SurveyGroupRatingDefinition(
        UUID.randomUUID(), "Test Nested Survey Group Definition Rating Item 3",
        SurveyGroupRatingType.YES_NO_NA));

    surveySectionDefinition3.addItemDefinition(surveyNestedGroupRatingsDefinition3);

    return surveyDefinition;
  }

  private static synchronized SurveyInstance getTestSurveyInstanceDetails(
      SurveyDefinition surveyDefinition)
  {
    return new SurveyInstance(UUID.randomUUID(), "Test Survey Instance", "Test Survey Instance",
        surveyDefinition);
  }

  private static synchronized SurveyRequest getTestSurveyRequestDetails(
      SurveyInstance surveyInstance)
  {
    return new SurveyRequest(UUID.randomUUID(), surveyInstance, "Marcus", "Portmann",
        "marcus@mmp.guru");
  }

  private void compareSurveyAudienceMembers(SurveyAudienceMember surveyAudienceMember1,
      SurveyAudienceMember surveyAudienceMember2)
  {
    assertEquals("The ID values for the two survey audience members do not match",
        surveyAudienceMember1.getId(), surveyAudienceMember2.getId());
    assertEquals("The first name values for the two survey audience members do not match",
        surveyAudienceMember1.getFirstName(), surveyAudienceMember2.getFirstName());
    assertEquals("The last name values for the two survey audience members do not match",
        surveyAudienceMember1.getLastName(), surveyAudienceMember2.getLastName());
    assertEquals("The email values for the two survey audience members do not match",
        surveyAudienceMember1.getEmail(), surveyAudienceMember2.getEmail());
  }

  private void compareSurveyAudiences(SurveyAudience surveyAudience1,
      SurveyAudience surveyAudience2)
  {
    assertEquals("The ID values for the two survey audiences do not match",
        surveyAudience1.getId(), surveyAudience2.getId());
    assertEquals("The name values for the two survey audiences do not match",
        surveyAudience1.getName(), surveyAudience2.getName());
  }

  private void compareSurveyDefinitions(SurveyDefinition surveyDefinition1,
      SurveyDefinition surveyDefinition2)
  {
    assertEquals("The ID values for the two survey definitions do not match",
        surveyDefinition1.getId(), surveyDefinition2.getId());
    assertEquals("The version values for the two survey definitions do not match",
        surveyDefinition1.getVersion(), surveyDefinition2.getVersion());
    assertEquals("The name values for the two survey definitions do not match",
        surveyDefinition1.getName(), surveyDefinition2.getName());
    assertEquals("The description values for the two survey definitions do not match",
        surveyDefinition1.getDescription(), surveyDefinition2.getDescription());

    assertEquals("The survey item definitions for the two survey definitions do not match",
        surveyDefinition1.getItemDefinitions().size(), surveyDefinition2.getItemDefinitions()
        .size());

    for (SurveyItemDefinition itemDefinition1 : surveyDefinition1.getItemDefinitions())
    {
      SurveyItemDefinition itemDefinition2 = surveyDefinition2.getItemDefinition(
          itemDefinition1.getId());

      assertNotNull("The survey item definition could not be found", itemDefinition2);

      compareSurveyItemDefinitions(itemDefinition1, itemDefinition2);
    }

    assertEquals("The survey group definitions for the two survey definitions do not match",
        surveyDefinition1.getGroupDefinitions().size(), surveyDefinition2.getGroupDefinitions()
        .size());

    for (SurveyGroupDefinition groupDefinition1 : surveyDefinition1.getGroupDefinitions())
    {
      SurveyGroupDefinition groupDefinition2 = surveyDefinition2.getGroupDefinition(
          groupDefinition1.getId());

      assertNotNull("The survey group definition could not be found", groupDefinition2);

      compareSurveyGroupDefinitions(groupDefinition1, groupDefinition2);
    }
  }

  private void compareSurveyDefinitions(SurveyDefinition surveyDefinition,
      SurveyDefinitionSummary surveyDefinitionSummary)
  {
    assertEquals(
        "The ID values for the survey definition and survey definition summary do not match",
        surveyDefinition.getId(), surveyDefinitionSummary.getId());
    assertEquals(
        "The version values for the survey definition and survey definition summary do not match",
        surveyDefinition.getVersion(), surveyDefinitionSummary.getVersion());
    assertEquals(
        "The name values for the survey definition and survey definition summary do not match",
        surveyDefinition.getName(), surveyDefinitionSummary.getName());
  }

  private void compareSurveyGroupDefinitions(SurveyGroupDefinition surveyGroupDefinition1,
      SurveyGroupDefinition surveyGroupDefinition2)
  {
    assertEquals("The ID values for the two survey group definitions do not match",
        surveyGroupDefinition1.getId(), surveyGroupDefinition2.getId());
    assertEquals("The name values for the two survey group definitions do not match",
        surveyGroupDefinition1.getName(), surveyGroupDefinition2.getName());
    assertEquals("The description values for the two survey group definitions do not match",
        surveyGroupDefinition1.getDescription(), surveyGroupDefinition2.getDescription());
    assertEquals(
        "The survey group member definitions for the two survey group definitions do not match",
        surveyGroupDefinition1.getGroupMemberDefinitions().size(),
        surveyGroupDefinition2.getGroupMemberDefinitions().size());

    for (SurveyGroupMemberDefinition member1 : surveyGroupDefinition1.getGroupMemberDefinitions())
    {
      SurveyGroupMemberDefinition member2 = surveyGroupDefinition2.getGroupMemberDefinition(
          member1.getId());

      assertNotNull("The survey group definition member could not be found", member2);

      compareSurveyGroupMemberDefinitions(member1, member2);
    }
  }

  private void compareSurveyGroupMemberDefinitions(
      SurveyGroupMemberDefinition surveyGroupMemberDefinition1,
      SurveyGroupMemberDefinition surveyGroupMemberDefinition2)
  {
    assertEquals("The ID values for the two survey group member definitions do not match",
        surveyGroupMemberDefinition1.getId(), surveyGroupMemberDefinition2.getId());
    assertEquals("The name values for the two survey group member definitions do not match",
        surveyGroupMemberDefinition1.getName(), surveyGroupMemberDefinition2.getName());
  }

  private void compareSurveyGroupRatingDefinitions(
      SurveyGroupRatingDefinition surveyGroupRatingDefinition1,
      SurveyGroupRatingDefinition surveyGroupRatingDefinition2)
  {
    assertEquals("The ID values for the two survey group rating item definitions do not match",
        surveyGroupRatingDefinition1.getId(), surveyGroupRatingDefinition2.getId());
    assertEquals("The name values for the two survey group rating item definitions do not match",
        surveyGroupRatingDefinition1.getName(), surveyGroupRatingDefinition2.getName());
    assertEquals(
        "The rating type values for the two survey group rating item definitions do not match",
        surveyGroupRatingDefinition1.getRatingType(), surveyGroupRatingDefinition2.getRatingType());
  }

  private void compareSurveyGroupRatingResponses(
      SurveyGroupRatingResponse surveyGroupRatingResponse1,
      SurveyGroupRatingResponse surveyGroupRatingResponse2)
  {
    assertEquals("The ID values for the two survey group rating responses do not match",
        surveyGroupRatingResponse1.getId(), surveyGroupRatingResponse2.getId());
    assertEquals(
        "The survey group member definition ID values for the two survey group rating responses do not match",
        surveyGroupRatingResponse1.getGroupMemberDefinitionId(),
        surveyGroupRatingResponse2.getGroupMemberDefinitionId());
    assertEquals(
        "The survey group ratings definition ID values for the two survey group rating responses do not match",
        surveyGroupRatingResponse1.getGroupRatingsDefinitionId(),
        surveyGroupRatingResponse2.getGroupRatingsDefinitionId());
    assertEquals(
        "The survey group rating definition ID values for the two survey group rating responses do not match",
        surveyGroupRatingResponse1.getGroupRatingDefinitionId(),
        surveyGroupRatingResponse2.getGroupRatingDefinitionId());
    assertEquals("The rating values for the two survey group rating responses do not match",
        surveyGroupRatingResponse1.getRating(), surveyGroupRatingResponse2.getRating());
  }

  private void compareSurveyInstances(SurveyInstance surveyInstance1,
      SurveyInstance surveyInstance2)
  {
    assertEquals("The ID values for the two survey instances do not match",
        surveyInstance1.getId(), surveyInstance2.getId());
    assertEquals("The name values for the two survey instances do not match",
        surveyInstance1.getName(), surveyInstance2.getName());
    assertEquals("The description values for the two survey instances do not match",
        surveyInstance1.getDescription(), surveyInstance2.getDescription());
  }

  private void compareSurveyItemDefinitions(SurveyItemDefinition surveyItemDefinition1,
      SurveyItemDefinition surveyItemDefinition2)
  {
    assertEquals("The ID values for the two survey item definitions do not match",
        surveyItemDefinition1.getId(), surveyItemDefinition2.getId());
    assertEquals("The type ID values for the two survey item definitions do not match",
        surveyItemDefinition1.getTypeId(), surveyItemDefinition2.getTypeId());
    assertEquals("The name values for the two survey item definitions do not match",
        surveyItemDefinition1.getName(), surveyItemDefinition2.getName());
    assertEquals("The label values for the two survey item definitions do not match",
        surveyItemDefinition1.getLabel(), surveyItemDefinition2.getLabel());
    assertEquals("The description values for the two survey item definitions do not match",
        surveyItemDefinition1.getDescription(), surveyItemDefinition2.getDescription());

    if (surveyItemDefinition1 instanceof SurveyGroupRatingsDefinition)
    {
      SurveyGroupRatingsDefinition surveyGroupRatingsDefinition1 =
          (SurveyGroupRatingsDefinition) surveyItemDefinition1;
      SurveyGroupRatingsDefinition surveyGroupRatingsDefinition2 =
          (SurveyGroupRatingsDefinition) surveyItemDefinition2;

      assertEquals(
          "The display ratings using gradient values for the two survey group ratings definitions do not match",
          surveyGroupRatingsDefinition1.getDisplayRatingsUsingGradient(),
          surveyGroupRatingsDefinition2.getDisplayRatingsUsingGradient());

      for (SurveyGroupRatingDefinition surveyGroupRatingDefinition1 :
          surveyGroupRatingsDefinition1.getGroupRatingDefinitions())
      {
        SurveyGroupRatingDefinition surveyGroupRatingDefinition2 =
            surveyGroupRatingsDefinition2.getGroupRatingDefinition(
            surveyGroupRatingDefinition1.getId());

        assertNotNull("The survey group rating definition could not be found",
            surveyGroupRatingsDefinition2);

        compareSurveyGroupRatingDefinitions(surveyGroupRatingDefinition1,
            surveyGroupRatingDefinition2);
      }
    }
  }

  private void compareSurveyRequests(SurveyRequest surveyRequest1, SurveyRequest surveyRequest2)
  {
    assertEquals("The ID values for the two survey requests do not match", surveyRequest1.getId(),
        surveyRequest2.getId());
    assertEquals("The status values for the two survey requests do not match",
        surveyRequest1.getStatus(), surveyRequest2.getStatus());
    assertEquals("The first name values for the two survey requests do not match",
        surveyRequest1.getFirstName(), surveyRequest2.getFirstName());
    assertEquals("The last name values for the two survey requests do not match",
        surveyRequest1.getLastName(), surveyRequest2.getLastName());
    assertEquals("The e-mail values for the two survey requests do not match",
        surveyRequest1.getEmail(), surveyRequest2.getEmail());
    assertEquals("The requested values for the two survey requests do not match",
        surveyRequest1.getRequested(), surveyRequest2.getRequested());
    assertEquals("The requested as string values for the two survey requests do not match",
        surveyRequest1.getRequestedAsString(), surveyRequest2.getRequestedAsString());
    assertEquals("The status values for the two survey requests do not match",
        surveyRequest1.getStatus(), surveyRequest2.getStatus());
    assertEquals("The send attempts values for the two survey requests do not match",
        surveyRequest1.getSendAttempts(), surveyRequest2.getSendAttempts());
    assertEquals("The lock name attempts values for the two survey requests do not match",
        surveyRequest1.getLockName(), surveyRequest2.getLockName());
    assertEquals("The last processed values for the two survey requests do not match",
        surveyRequest1.getLastProcessed(), surveyRequest2.getLastProcessed());
  }

  private void compareSurveyResponses(SurveyResponse surveyResponse1,
      SurveyResponse surveyResponse2)
  {
    assertEquals("The ID values for the two survey responses do not match",
        surveyResponse1.getId(), surveyResponse2.getId());
    assertEquals("The received values for the two survey responses do not match",
        surveyResponse1.getResponded(), surveyResponse2.getResponded());
    assertEquals("The name values for the two survey responses do not match",
        surveyResponse1.getName(), surveyResponse2.getName());

    assertEquals("The survey group rating responses for the two survey definitions do not match",
        surveyResponse1.getGroupRatingResponses().size(), surveyResponse2.getGroupRatingResponses()
        .size());

    for (SurveyGroupRatingResponse groupRatingResponse1 : surveyResponse1.getGroupRatingResponses())
    {
      SurveyGroupRatingResponse groupRatingResponse2 = surveyResponse2.getGroupRatingResponse(
          groupRatingResponse1.getId());

      assertNotNull("The survey group rating response could not be found", groupRatingResponse2);

      compareSurveyGroupRatingResponses(groupRatingResponse1, groupRatingResponse2);
    }
  }

  private void compareSurveyResponses(SurveyResponse surveyResponse,
      SurveyResponseSummary surveyResponseSummary)
  {
    assertEquals("The ID values for the survey response and survey response summary do not match",
        surveyResponse.getId(), surveyResponseSummary.getId());
    assertEquals(
        "The received values for the survey response and survey response summary do not match",
        surveyResponse.getResponded(), surveyResponseSummary.getResponded());
    assertEquals(
        "The name values for the survey response and survey response summary do not match",
        surveyResponse.getName(), surveyResponseSummary.getName());
  }

  private void randomizeSurveyResponse(SurveyResponse surveyResponse)
  {
    for (SurveyGroupRatingResponse groupRatingResponse : surveyResponse.getGroupRatingResponses())
    {
      SurveyGroupRatingDefinition groupRatingDefinition = surveyResponse.getInstance()
          .getDefinition().getGroupRatingDefinition(
          groupRatingResponse.getGroupRatingDefinitionId());

      if (groupRatingDefinition.getRatingType() == SurveyGroupRatingType.ONE_TO_TEN)
      {
        groupRatingResponse.setRating(ThreadLocalRandom.current().nextInt(1, 10 + 1));
      }
      else if (groupRatingDefinition.getRatingType() == SurveyGroupRatingType.YES_NO_NA)
      {
        groupRatingResponse.setRating(ThreadLocalRandom.current().nextInt(-1, 2));
      }
    }
  }
}
