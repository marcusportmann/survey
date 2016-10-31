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
import java.util.List;
import java.util.UUID;

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
  {
    SurveyDefinition surveyDefinition = getCTOValuesSurveyDefinitionDetails();

    SurveyInstance surveyInstance = new SurveyInstance(UUID.fromString(
        "b222aa15-715f-4752-923d-8f33ee8a1736"), "CTO ELT Values - September 2016",
        "CTO ELT Values - September 2016", surveyDefinition);

    SurveyRequest surveyRequest = new SurveyRequest(UUID.fromString(
        "54a751f6-0f32-48bd-8c6c-665e3ac1906b"), surveyInstance, "Marcus", "Portmann",
        "marcus@mmp.guru");

    SurveyResponse marcusSurveyResponse = new SurveyResponse(UUID.fromString(
        "18f3fcc1-06b2-4dc4-90ea-7a8904009488"), surveyInstance, surveyRequest);

    SurveyResponse anonymousSurveyResponse = new SurveyResponse(UUID.fromString(
        "9271229e-0824-4098-8477-1a564c0acca1"), surveyInstance);

    System.out.println("Survey Definition: " + surveyDefinition.getData());

    System.out.println("Survey Response (Marcus Portmann): " + marcusSurveyResponse.getData());

    System.out.println("Survey Response (Anonymous): " + anonymousSurveyResponse.getData());
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
   * Test the remove survey group rating item definition functionality.
   */
  @Test
  public void removeSurveyGroupDefinitionRatingItem()
    throws Exception
  {
    Organisation organisation = getTestOrganisationDetails();

    securityService.createOrganisation(organisation, true);

    SurveyDefinition surveyDefinition = getTestSurveyDefinitionDetails(organisation);

    surveyDefinition = surveyService.saveSurveyDefinition(surveyDefinition);

    surveyDefinition = surveyService.getSurveyDefinition(surveyDefinition.getId(), 1);

    surveyDefinition.getGroupRatingItemDefinitions().remove(
        surveyDefinition.getGroupRatingItemDefinitions().iterator().next());

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

    SurveyGroupDefinition surveyGroupDefinition = new SurveyGroupDefinition(UUID.randomUUID(),
        "CTO ELT", "CTO ELT");

    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "CTO ELT"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Peter"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Adriaan"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Alapan"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Dan"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Daryl"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "David"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Francois"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "James"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Kersh"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Kevin"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Linde-Marie"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Manoj"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Marcus"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Mercia"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Nicole"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Lawrence"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Richard"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Sandra"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Tendai"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Debbie"));

    surveyDefinition.addGroupDefinition(surveyGroupDefinition);

    surveyDefinition.addGroupRatingItemDefinition(new SurveyGroupRatingItemDefinition(
        UUID.randomUUID(), "Accountability", surveyGroupDefinition.getId(),
        SurveyGroupRatingItemType.YES_NO_NA));
    surveyDefinition.addGroupRatingItemDefinition(new SurveyGroupRatingItemDefinition(
        UUID.randomUUID(), "Competence", surveyGroupDefinition.getId(), SurveyGroupRatingItemType
        .YES_NO_NA));
    surveyDefinition.addGroupRatingItemDefinition(new SurveyGroupRatingItemDefinition(
        UUID.randomUUID(), "Courage", surveyGroupDefinition.getId(), SurveyGroupRatingItemType
        .YES_NO_NA));
    surveyDefinition.addGroupRatingItemDefinition(new SurveyGroupRatingItemDefinition(
        UUID.randomUUID(), "Fairness", surveyGroupDefinition.getId(), SurveyGroupRatingItemType
        .YES_NO_NA));
    surveyDefinition.addGroupRatingItemDefinition(new SurveyGroupRatingItemDefinition(
        UUID.randomUUID(), "Integrity", surveyGroupDefinition.getId(), SurveyGroupRatingItemType
        .YES_NO_NA));
    surveyDefinition.addGroupRatingItemDefinition(new SurveyGroupRatingItemDefinition(
        UUID.randomUUID(), "Openness", surveyGroupDefinition.getId(), SurveyGroupRatingItemType
        .YES_NO_NA));
    surveyDefinition.addGroupRatingItemDefinition(new SurveyGroupRatingItemDefinition(
        UUID.randomUUID(), "Positive Attitude", surveyGroupDefinition.getId(),
        SurveyGroupRatingItemType.YES_NO_NA));
    surveyDefinition.addGroupRatingItemDefinition(new SurveyGroupRatingItemDefinition(
        UUID.randomUUID(), "Teamwork", surveyGroupDefinition.getId(), SurveyGroupRatingItemType
        .YES_NO_NA));
    surveyDefinition.addGroupRatingItemDefinition(new SurveyGroupRatingItemDefinition(
        UUID.randomUUID(), "Making a difference", surveyGroupDefinition.getId(),
        SurveyGroupRatingItemType.YES_NO_NA));
    surveyDefinition.addGroupRatingItemDefinition(new SurveyGroupRatingItemDefinition(
        UUID.randomUUID(), "Trust", surveyGroupDefinition.getId(), SurveyGroupRatingItemType
        .YES_NO_NA));

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
        "Test Survey Template Name", "Test Survey Template Description");

    SurveySectionDefinition surveySectionDefinition1 = new SurveySectionDefinition(
        UUID.randomUUID(), "Test Survey Section Definition Name 1",
        "Test Survey Section Definition Description 1");
    SurveySectionDefinition surveySectionDefinition2 = new SurveySectionDefinition(
        UUID.randomUUID(), "Test Survey Section Definition Name 2",
        "Test Survey Section Definition Description 2");
    SurveySectionDefinition surveySectionDefinition3 = new SurveySectionDefinition(
        UUID.randomUUID(), "Test Survey Section Definition Name 3",
        "Test Survey Section Definition Description 3");

    surveyDefinition.addSectionDefinition(surveySectionDefinition1);
    surveyDefinition.addSectionDefinition(surveySectionDefinition2);
    surveyDefinition.addSectionDefinition(surveySectionDefinition3);

    SurveyGroupDefinition surveyGroupDefinition = new SurveyGroupDefinition(UUID.randomUUID(),
        "Test Survey Group Definition Name", "Test Survey Group Definition Description");

    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Test Survey Group Definition Member 1"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Test Survey Group Definition Member 2"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Test Survey Group Definition Member 4"));
    surveyGroupDefinition.addGroupMemberDefinition(new SurveyGroupMemberDefinition(
        UUID.randomUUID(), "Test Survey Group Definition Member 3"));

    surveyDefinition.addGroupDefinition(surveyGroupDefinition);

    surveyDefinition.addGroupRatingItemDefinition(new SurveyGroupRatingItemDefinition(
        UUID.randomUUID(), "Test Survey Group Definition Rating Item 1",
        surveyGroupDefinition.getId(), SurveyGroupRatingItemType.YES_NO_NA));
    surveyDefinition.addGroupRatingItemDefinition(new SurveyGroupRatingItemDefinition(
        UUID.randomUUID(), "Test Survey Group Definition Rating Item 2",
        surveyGroupDefinition.getId(), SurveyGroupRatingItemType.YES_NO_NA));
    surveyDefinition.addGroupRatingItemDefinition(new SurveyGroupRatingItemDefinition(
        UUID.randomUUID(), "Test Survey Group Definition Rating Item 3",
        surveyGroupDefinition.getId(), SurveyGroupRatingItemType.YES_NO_NA));

    surveySectionDefinition1.addGroupRatingItemDefinition(new SurveyGroupRatingItemDefinition(
        UUID.randomUUID(), "Test Nested Survey Group Definition Rating Item 1",
        surveyGroupDefinition.getId(), SurveyGroupRatingItemType.YES_NO_NA));
    surveySectionDefinition2.addGroupRatingItemDefinition(new SurveyGroupRatingItemDefinition(
        UUID.randomUUID(), "Test Nested Survey Group Definition Rating Item 2",
        surveyGroupDefinition.getId(), SurveyGroupRatingItemType.YES_NO_NA));
    surveySectionDefinition3.addGroupRatingItemDefinition(new SurveyGroupRatingItemDefinition(
        UUID.randomUUID(), "Test Nested Survey Group Definition Rating Item 3",
        surveyGroupDefinition.getId(), SurveyGroupRatingItemType.YES_NO_NA));

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

    assertEquals("The survey section definitions for the two survey definitions do not match",
        surveyDefinition1.getSectionDefinitions().size(), surveyDefinition2.getSectionDefinitions()
        .size());

    for (SurveySectionDefinition sectionDefinition1 : surveyDefinition1.getSectionDefinitions())
    {
      SurveySectionDefinition sectionDefinition2 = surveyDefinition2.getSectionDefinition(
          sectionDefinition1.getId());

      assertNotNull("The survey section definition could not be found", sectionDefinition2);

      compareSurveySectionDefinitions(sectionDefinition1, sectionDefinition2);
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

    assertEquals(
        "The survey group rating item definitions for the two survey definitions do not match",
        surveyDefinition1.getGroupRatingItemDefinitions().size(),
        surveyDefinition2.getGroupRatingItemDefinitions().size());

    for (SurveyGroupRatingItemDefinition groupRatingItemDefinition1 :
        surveyDefinition1.getGroupRatingItemDefinitions())
    {
      SurveyGroupRatingItemDefinition groupRatingItemDefinition2 =
          surveyDefinition2.getGroupRatingItemDefinition(groupRatingItemDefinition1.getId());

      assertNotNull("The survey group rating item definition could not be found",
          groupRatingItemDefinition2);

      compareSurveyGroupRatingItemDefinitions(groupRatingItemDefinition1,
          groupRatingItemDefinition2);
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

  private void compareSurveyGroupRatingItemDefinitions(
      SurveyGroupRatingItemDefinition surveyGroupRatingItemDefinition1,
      SurveyGroupRatingItemDefinition surveyGroupRatingItemDefinition2)
  {
    assertEquals("The ID values for the two survey group rating item definitions do not match",
        surveyGroupRatingItemDefinition1.getId(), surveyGroupRatingItemDefinition2.getId());
    assertEquals("The name values for the two survey group rating item definitions do not match",
        surveyGroupRatingItemDefinition1.getName(), surveyGroupRatingItemDefinition2.getName());
    assertEquals(
        "The rating type values for the two survey group rating item definitions do not match",
        surveyGroupRatingItemDefinition1.getRatingType(),
        surveyGroupRatingItemDefinition2.getRatingType());
  }

  private void compareSurveyGroupRatingItemResponses(
      SurveyGroupRatingItemResponse surveyGroupRatingItemResponse1,
      SurveyGroupRatingItemResponse surveyGroupRatingItemResponse2)
  {
    assertEquals("The ID values for the two survey group rating item responses do not match",
        surveyGroupRatingItemResponse1.getId(), surveyGroupRatingItemResponse2.getId());
    assertEquals(
        "The survey group member definition ID values for the two survey group rating item responses do not match",
        surveyGroupRatingItemResponse1.getGroupMemberDefinitionId(),
        surveyGroupRatingItemResponse2.getGroupMemberDefinitionId());
    assertEquals(
        "The survey group member definition name values for the two survey group rating item responses do not match",
        surveyGroupRatingItemResponse1.getGroupMemberDefinitionName(),
        surveyGroupRatingItemResponse2.getGroupMemberDefinitionName());
    assertEquals(
        "The survey group rating item definition ID values for the two survey group rating item responses do not match",
        surveyGroupRatingItemResponse1.getGroupRatingItemDefinitionId(),
        surveyGroupRatingItemResponse2.getGroupRatingItemDefinitionId());
    assertEquals(
        "The survey group rating item definition name values for the two survey group rating item responses do not match",
        surveyGroupRatingItemResponse1.getGroupRatingItemDefinitionName(),
        surveyGroupRatingItemResponse2.getGroupRatingItemDefinitionName());
    assertEquals(
        "The survey group rating item definition rating type values for the two survey group rating item responses do not match",
        surveyGroupRatingItemResponse1.getGroupRatingItemDefinitionRatingType(),
        surveyGroupRatingItemResponse2.getGroupRatingItemDefinitionRatingType());
    assertEquals("The rating values for the two survey group rating item responses do not match",
        surveyGroupRatingItemResponse1.getRating(), surveyGroupRatingItemResponse2.getRating());
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

    assertEquals(
        "The survey group rating item responses for the two survey definitions do not match",
        surveyResponse1.getGroupRatingItemResponses().size(),
        surveyResponse2.getGroupRatingItemResponses().size());

    for (SurveyGroupRatingItemResponse groupRatingItemResponse1 :
        surveyResponse1.getGroupRatingItemResponses())
    {
      SurveyGroupRatingItemResponse groupRatingItemResponse2 =
          surveyResponse2.getGroupRatingItemResponse(groupRatingItemResponse1.getId());

      assertNotNull("The survey group rating item response could not be found",
          groupRatingItemResponse2);

      compareSurveyGroupRatingItemResponses(groupRatingItemResponse1, groupRatingItemResponse2);
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

  private void compareSurveySectionDefinitions(SurveySectionDefinition surveySectionDefinition1,
      SurveySectionDefinition surveySectionDefinition2)
  {
    assertEquals("The ID values for the two survey section definitions do not match",
        surveySectionDefinition1.getId(), surveySectionDefinition2.getId());
    assertEquals("The name values for the two survey section definitions do not match",
        surveySectionDefinition1.getName(), surveySectionDefinition2.getName());
    assertEquals("The description values for the two survey section definitions do not match",
        surveySectionDefinition1.getDescription(), surveySectionDefinition2.getDescription());

    assertEquals(
        "The survey group rating item definitions for the two survey section definitions do not match",
        surveySectionDefinition1.getGroupRatingItemDefinitions().size(),
        surveySectionDefinition1.getGroupRatingItemDefinitions().size());

    for (SurveyGroupRatingItemDefinition groupRatingItem1 :
        surveySectionDefinition1.getGroupRatingItemDefinitions())
    {
      SurveyGroupRatingItemDefinition groupRatingItem2 =
          surveySectionDefinition1.getGroupRatingItemDefinition(groupRatingItem1.getId());

      assertNotNull("The survey group rating item definition could not be found", groupRatingItem2);

      compareSurveyGroupRatingItemDefinitions(groupRatingItem1, groupRatingItem2);
    }
  }
}
