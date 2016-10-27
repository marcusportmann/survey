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

package guru.mmp.survey.tests;

//~--- non-JDK imports --------------------------------------------------------

import guru.mmp.application.test.ApplicationClassRunner;
import guru.mmp.application.test.ApplicationDataSourceSQLResource;
import guru.mmp.survey.model.*;
import org.junit.Test;
import org.junit.runner.RunWith;

import javax.inject.Inject;
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
@ApplicationDataSourceSQLResource(path = "guru/mmp/survey/persistence/SurveyH2.sql")
public class SurveyServiceTest
{
  @Inject
  private ISurveyService surveyService;

  /**
   * Test the get CTO values survey definition functionality.
   */
  @Test
  public void getCTOValuesSurveyDefinitionTest()
  {
    SurveyDefinition surveyDefinition = getCTOValuesSurveyDefinition();

    SurveyInstance surveyInstance = new SurveyInstance(UUID.fromString("b222aa15-715f-4752-923d-8f33ee8a1736"), "CTO ELT Values Survey - September 2016", surveyDefinition);

    SurveyRequest surveyRequest = new SurveyRequest(UUID.fromString("54a751f6-0f32-48bd-8c6c-665e3ac1906b"),  surveyInstance, "Marcus", "Portmann", "marcus@mmp.guru");

    SurveyResponse marcusSurveyResponse = new SurveyResponse(UUID.fromString("18f3fcc1-06b2-4dc4-90ea-7a8904009488"), surveyInstance, surveyRequest);

    SurveyResponse anonymousSurveyResponse = new SurveyResponse(UUID.fromString("9271229e-0824-4098-8477-1a564c0acca1"), surveyInstance);

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
    SurveyDefinition surveyDefinition = getTestSurveyDefinition();

    surveyService.saveSurveyDefinition(surveyDefinition);

    surveyDefinition = surveyService.getSurveyDefinition(surveyDefinition.getId(), 1);

    SurveyGroupDefinition firstSurveyGroupDefinition = surveyDefinition.getGroupDefinitions()
        .iterator().next();

    firstSurveyGroupDefinition.removeGroupMemberDefinition(
        firstSurveyGroupDefinition.getGroupMemberDefinitions().get(0).getId());

    surveyService.saveSurveyDefinition(surveyDefinition);

    SurveyDefinition retrievedSurveyDefinition = surveyService.getSurveyDefinition(
        surveyDefinition.getId(), surveyDefinition.getVersion());

    compareSurveyDefinitions(surveyDefinition, retrievedSurveyDefinition);
  }

  /**
   * Test the remove survey group rating item definition functionality.
   */
  @Test
  public void removeSurveyGroupDefinitionRatingItem()
    throws Exception
  {
    SurveyDefinition surveyDefinition = getTestSurveyDefinition();

    surveyService.saveSurveyDefinition(surveyDefinition);

    surveyDefinition = surveyService.getSurveyDefinition(surveyDefinition.getId(), 1);

    surveyDefinition.getGroupRatingItemDefinitions().remove(
        surveyDefinition.getGroupRatingItemDefinitions().iterator().next());

    surveyService.saveSurveyDefinition(surveyDefinition);

    SurveyDefinition retrievedSurveyDefinition = surveyService.getSurveyDefinition(
        surveyDefinition.getId(), surveyDefinition.getVersion());

    compareSurveyDefinitions(surveyDefinition, retrievedSurveyDefinition);
  }

  /**
   * Test the remove survey group definition functionality.
   */
  @Test
  public void removeSurveyGroupDefinitionTest()
    throws Exception
  {
    SurveyDefinition surveyDefinition = getTestSurveyDefinition();

    surveyService.saveSurveyDefinition(surveyDefinition);

    surveyDefinition = surveyService.getSurveyDefinition(surveyDefinition.getId(), 1);

    SurveyGroupDefinition firstSurveyGroupDefinition = surveyDefinition.getGroupDefinitions()
        .iterator().next();

    surveyDefinition.removeGroupDefinition(firstSurveyGroupDefinition.getId());

    surveyService.saveSurveyDefinition(surveyDefinition);

    SurveyDefinition retrievedSurveyDefinition = surveyService.getSurveyDefinition(
        surveyDefinition.getId(), surveyDefinition.getVersion());

    compareSurveyDefinitions(surveyDefinition, retrievedSurveyDefinition);
  }

  /**
   * Test the save CTO Values survey response functionality.
   */
  @Test
  public void saveCTOValuesSurveyResponseTest()
    throws Exception
  {
    SurveyDefinition surveyDefinition = getCTOValuesSurveyDefinition();

    surveyService.saveSurveyDefinition(surveyDefinition);

    SurveyInstance surveyInstance = getCTOValuesSurveyInstance(surveyDefinition);

    surveyService.saveSurveyInstance(surveyInstance);

    SurveyResponse surveyResponse = new SurveyResponse(surveyInstance);

    surveyService.saveSurveyResponse(surveyResponse);

    SurveyResponse retrievedSurveyResponse = surveyService.getSurveyResponse(
        surveyResponse.getId());

    compareSurveyResponses(surveyResponse, retrievedSurveyResponse);
  }

  /**
   * Test the save new survey definition functionality.
   */
  @Test
  public void saveNewSurveyDefinitionTest()
    throws Exception
  {
    SurveyDefinition surveyDefinition = getTestSurveyDefinition();

    surveyService.saveSurveyDefinition(surveyDefinition);

    SurveyDefinition retrievedSurveyDefinition = surveyService.getSurveyDefinition(
        surveyDefinition.getId(), 1);

    compareSurveyDefinitions(surveyDefinition, retrievedSurveyDefinition);
  }

  /**
   * Test the save new survey definition version functionality.
   */
  @Test
  public void saveNewSurveyDefinitionVersionTest()
    throws Exception
  {
    SurveyDefinition surveyDefinition = getTestSurveyDefinition();

    SurveyDefinition savedSurveyDefinition = surveyService.saveSurveyDefinition(surveyDefinition);

    compareSurveyDefinitions(surveyDefinition, savedSurveyDefinition);

    SurveyInstance surveyInstance = getTestSurveyInstance(surveyDefinition);

    surveyService.saveSurveyInstance(surveyInstance);

    SurveyInstance retrievedSurveyInstance = surveyService.getSurveyInstance(
        surveyInstance.getId());

    compareSurveyInstances(surveyInstance, retrievedSurveyInstance);

    savedSurveyDefinition = surveyService.saveSurveyDefinition(savedSurveyDefinition);

    SurveyDefinition retrievedSurveyDefinition = surveyService.getSurveyDefinition(
        surveyDefinition.getId(), savedSurveyDefinition.getVersion());

    compareSurveyDefinitions(savedSurveyDefinition, retrievedSurveyDefinition);

    assertEquals("The version number for the updated survey definition is incorrect", 2,
        surveyService.getLatestVersionNumberForSurveyDefinition(surveyDefinition.getId()));

    retrievedSurveyDefinition = surveyService.getLatestVersionForSurveyDefinition(
        surveyDefinition.getId());

    compareSurveyDefinitions(savedSurveyDefinition, retrievedSurveyDefinition);

    List<SurveyDefinition> retrievedSurveyDefinitions =
        surveyService.getLatestSurveyDefinitionsForOrganisation(
        surveyDefinition.getOrganisationId());

    for (SurveyDefinition tmpSurveyDefinition : retrievedSurveyDefinitions)
    {
      if (tmpSurveyDefinition.getId().equals(surveyDefinition.getId()))
      {
        compareSurveyDefinitions(savedSurveyDefinition, tmpSurveyDefinition);
      }
    }

    assertEquals("The number of latest survey definitions for the organisation is incorrect",
        retrievedSurveyDefinitions.size(),
        surveyService.getNumberOfLatestSurveyDefinitionsForOrganisation(
        surveyDefinition.getOrganisationId()));

    retrievedSurveyDefinitions = surveyService.getFilteredLatestSurveyDefinitionsForOrganisation(
        surveyDefinition.getOrganisationId(), surveyDefinition.getName());

    assertEquals(
        "The number of filtered latest survey definitions for the organisation is incorrect", 1,
        retrievedSurveyDefinitions.size());

    for (SurveyDefinition tmpSurveyDefinition : retrievedSurveyDefinitions)
    {
      if (tmpSurveyDefinition.getId().equals(surveyDefinition.getId()))
      {
        compareSurveyDefinitions(savedSurveyDefinition, tmpSurveyDefinition);
      }
    }

    assertEquals(
        "The number of filtered latest survey definitions for the organisation is incorrect", 1,
        surveyService.getNumberOfFilteredLatestSurveyDefinitionsForOrganisation(
        surveyDefinition.getOrganisationId(), surveyDefinition.getName()));

  }

  /**
   * Test the save updated survey definition functionality.
   */
  @Test
  public void saveUpdatedSurveyDefinitionTest()
    throws Exception
  {
    SurveyDefinition surveyDefinition = getTestSurveyDefinition();

    surveyService.saveSurveyDefinition(surveyDefinition);

    surveyDefinition = surveyService.getSurveyDefinition(surveyDefinition.getId(), 1);

    surveyDefinition.setName(surveyDefinition.getName() + " Updated");
    surveyDefinition.setDescription(surveyDefinition.getDescription() + " Updated");

    surveyService.saveSurveyDefinition(surveyDefinition);

    SurveyDefinition retrievedSurveyDefinition = surveyService.getSurveyDefinition(
        surveyDefinition.getId(), surveyDefinition.getVersion());

    compareSurveyDefinitions(surveyDefinition, retrievedSurveyDefinition);
  }

  /**
   * Test the survey audience functionality.
   *
   */
  @Test
  public void surveyAudienceTest()
    throws Exception
  {
    SurveyAudience surveyAudience = getTestSurveyAudience();

    surveyService.saveSurveyAudience(surveyAudience);

    SurveyAudience retrievedSurveyAudience = surveyService.getSurveyAudience(
        surveyAudience.getId());

    compareSurveyAudiences(surveyAudience, retrievedSurveyAudience);

    SurveyAudienceMember retrievedSurveyAudienceMember = surveyService.getSurveyAudienceMember(
        surveyAudience.getMembers().get(0).getId());

    compareSurveyAudienceMembers(surveyAudience.getMembers().get(0), retrievedSurveyAudienceMember);

    List<SurveyAudienceMember> retrievedSurveyAudienceMembers =
        surveyService.getMembersForSurveyAudience(surveyAudience.getId());

    assertEquals(
        "Failed to retrieve the correct number of survey audience members for the survey audience ("
        + surveyAudience.getId() + ")", surveyAudience.getMembers().size(),
        retrievedSurveyAudienceMembers.size());

    for (SurveyAudienceMember surveyAudienceMember : surveyAudience.getMembers())
    {
      for (SurveyAudienceMember tmpSurveyAudienceMember : retrievedSurveyAudienceMembers)
      {
        if (surveyAudienceMember.getId().equals(tmpSurveyAudienceMember.getId()))
        {
          compareSurveyAudienceMembers(surveyAudienceMember, tmpSurveyAudienceMember);
        }
      }
    }

    assertEquals("Failed to retrieve the correct number of survey audiences for the organisation ("
        + surveyAudience.getOrganisationId() + ")", 1,
        surveyService.getNumberOfSurveyAudiencesForOrganisation(
        surveyAudience.getOrganisationId()));

    assertEquals(
        "Failed to retrieve the correct number of survey audience members for the survey audience ("
        + surveyAudience.getId() + ")", surveyAudience.getMembers().size(),
        surveyService.getNumberOfMembersForSurveyAudience(surveyAudience.getId()));

    assertEquals(
        "Failed to retrieve the correct number of filtered survey audiences for the organisation ("
        + surveyAudience.getOrganisationId() + ")", 1,
        surveyService.getNumberOfFilteredSurveyAudiencesForOrganisation(
        surveyAudience.getOrganisationId(), "Test"));

    retrievedSurveyAudience = surveyService.getFilteredSurveyAudiencesForOrganisation(
        surveyAudience.getOrganisationId(), "Test").get(0);

    compareSurveyAudiences(surveyAudience, retrievedSurveyAudience);

    assertEquals(
        "Failed to retrieve the correct number of filtered survey audience members for the survey audience ("
        + surveyAudience.getId() + ")", 1,
        surveyService.getNumberOfFilteredMembersForSurveyAudience(surveyAudience.getId(),
        "Test First Name 1"));

    retrievedSurveyAudienceMember = surveyService.getFilteredMembersForSurveyAudience(
        surveyAudience.getId(), "Test First Name 1").get(0);

    compareSurveyAudienceMembers(surveyAudience.getMembers().get(0), retrievedSurveyAudienceMember);

  }

  /**
   * Test the survey request functionality.
   */
  @Test
  public void surveyRequestTest()
    throws Exception
  {
    SurveyDefinition surveyDefinition = getTestSurveyDefinition();

    surveyService.saveSurveyDefinition(surveyDefinition);

    SurveyInstance surveyInstance = getTestSurveyInstance(surveyDefinition);

    surveyService.saveSurveyInstance(surveyInstance);

    SurveyRequest surveyRequest = getTestSurveyRequest(surveyInstance);

    surveyService.saveSurveyRequest(surveyRequest);

    SurveyRequest retrievedSurveyRequest = surveyService.getSurveyRequest(surveyRequest.getId());

    compareSurveyRequests(surveyRequest, retrievedSurveyRequest);

    assertEquals("The number of survey requests for the survey instance is not correct", 1, surveyService.getNumberOfSurveyRequestsForSurveyInstance(surveyInstance.getId()));

    List<SurveyRequest> surveyRequests = surveyService.getSurveyRequestsForSurveyInstance(surveyInstance.getId());

    assertEquals("The number of survey requests for the survey instance is not correct", 1, surveyRequests.size());

    compareSurveyRequests(surveyRequest, surveyRequests.get(0));

    assertEquals("The number of filtered survey requests for the survey instance is not correct", 1, surveyService.getNumberOfFilteredSurveyRequestsForSurveyInstance(surveyInstance.getId(), "Marcus"));

    surveyRequests = surveyService.getFilteredSurveyRequestsForSurveyInstance(surveyInstance.getId(), "Marcus");

    assertEquals("The number of filtered survey requests for the survey instance is not correct", 1, surveyRequests.size());

    compareSurveyRequests(surveyRequest, surveyRequests.get(0));
  }

  /**
   * Test the survey response functionality.
   */
  @Test
  public void surveyResponseTest()
    throws Exception
  {
    SurveyDefinition surveyDefinition = getTestSurveyDefinition();

    surveyService.saveSurveyDefinition(surveyDefinition);

    surveyDefinition = surveyService.getSurveyDefinition(surveyDefinition.getId(), 1);

    SurveyInstance surveyInstance = getTestSurveyInstance(surveyDefinition);

    surveyService.saveSurveyInstance(surveyInstance);

    SurveyRequest surveyRequest = getTestSurveyRequest(surveyInstance);

    surveyService.saveSurveyRequest(surveyRequest);

    SurveyResponse surveyResponse = new SurveyResponse(surveyInstance, surveyRequest);

    surveyService.saveSurveyResponse(surveyResponse);

    SurveyResponse retrievedSurveyResponse = surveyService.getSurveyResponse(
        surveyResponse.getId());

    compareSurveyResponses(surveyResponse, retrievedSurveyResponse);

    assertEquals("The number of survey responses for the survey instance is not correct", 1, surveyService.getNumberOfSurveyResponsesForSurveyInstance(surveyInstance.getId()));

    List<SurveyResponse> surveyResponses = surveyService.getSurveyResponsesForSurveyInstance(surveyInstance.getId());

    assertEquals("The number of survey responses for the survey instance is not correct", 1, surveyResponses.size());

    compareSurveyResponses(surveyResponse, surveyResponses.get(0));

    assertEquals("The number of filtered survey responses for the survey instance is not correct", 1, surveyService.getNumberOfFilteredSurveyResponsesForSurveyInstance(surveyInstance.getId(), "Marcus"));

    surveyResponses = surveyService.getFilteredSurveyResponsesForSurveyInstance(surveyInstance.getId(), "Marcus");

    assertEquals("The number of filtered survey responses for the survey instance is not correct", 1, surveyResponses.size());

    compareSurveyResponses(surveyResponse, surveyResponses.get(0));
  }

  private static synchronized SurveyDefinition getCTOValuesSurveyDefinition()
  {
    SurveyDefinition surveyDefinition = new SurveyDefinition(UUID.fromString(
        "706fb4a4-8ba8-11e6-ae22-56b6b6499611"), 1, UUID.fromString(
        "c1685b92-9fe5-453a-995b-89d8c0f29cb5"), "CTO ELT Values Survey", "CTO ELT Values Survey");

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

  private static synchronized SurveyInstance getCTOValuesSurveyInstance(
      SurveyDefinition surveyDefinition)
  {
    SurveyInstance surveyInstance = new SurveyInstance(UUID.randomUUID(),
        "CTO ELT Values Survey - September 2016", surveyDefinition);

    return surveyInstance;
  }

  private static synchronized SurveyAudience getTestSurveyAudience()
  {
    SurveyAudience surveyAudience = new SurveyAudience(UUID.randomUUID(), UUID.fromString(
        "c1685b92-9fe5-453a-995b-89d8c0f29cb5"), "Test Survey Audience");

    surveyAudience.addMember(new SurveyAudienceMember(UUID.randomUUID(), "Test First Name 1",
        "Test Last Name 1", "Test Email 1"));
    surveyAudience.addMember(new SurveyAudienceMember(UUID.randomUUID(), "Test First Name 2",
        "Test Last Name 2", "Test Email 2"));
    surveyAudience.addMember(new SurveyAudienceMember(UUID.randomUUID(), "Test First Name 3",
        "Test Last Name 3", "Test Email 3"));

    return surveyAudience;
  }

  private static synchronized SurveyDefinition getTestSurveyDefinition()
  {
    SurveyDefinition surveyDefinition = new SurveyDefinition(UUID.randomUUID(), 1, UUID.fromString(
        "c1685b92-9fe5-453a-995b-89d8c0f29cb5"), "Test Survey Template Name",
        "Test Survey Template Description");

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

  private static synchronized SurveyInstance getTestSurveyInstance(
      SurveyDefinition surveyDefinition)
  {
    SurveyInstance surveyInstance = new SurveyInstance(UUID.randomUUID(), "Test Survey Instance",
        surveyDefinition);

    return surveyInstance;
  }

  private static synchronized SurveyRequest getTestSurveyRequest(SurveyInstance surveyInstance)
  {
    SurveyRequest surveyRequest = new SurveyRequest(UUID.randomUUID(), surveyInstance, "Marcus",
        "Portmann", "marcus@mmp.guru");

    return surveyRequest;
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

    for (SurveyAudienceMember member1 : surveyAudience1.getMembers())
    {
      SurveyAudienceMember member2 = surveyAudience2.getMember(member1.getId());

      assertNotNull("The survey audience member could not be found", member2);

      compareSurveyAudienceMembers(member1, member2);
    }
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
  }

  private void compareSurveyRequests(SurveyRequest surveyRequest1, SurveyRequest surveyRequest2)
  {
    assertEquals("The ID values for the two survey requests do not match", surveyRequest1.getId(),
        surveyRequest2.getId());
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
