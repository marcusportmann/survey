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
    System.out.println(getCTOValuesSurveyDefinition().getData());
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
  }

  /**
   * Test the save survey response functionality.
   */
  @Test
  public void saveSurveyResponseTest()
    throws Exception
  {
    SurveyDefinition surveyDefinition = getTestSurveyDefinition();

    surveyService.saveSurveyDefinition(surveyDefinition);

    surveyDefinition = surveyService.getSurveyDefinition(surveyDefinition.getId(), 1);

    SurveyDefinition retrievedSurveyDefinition = surveyService.getSurveyDefinition(
        surveyDefinition.getId(), surveyDefinition.getVersion());

    compareSurveyDefinitions(surveyDefinition, retrievedSurveyDefinition);

    SurveyInstance surveyInstance = getTestSurveyInstance(surveyDefinition);

    surveyService.saveSurveyInstance(surveyInstance);

    SurveyInstance retrievedSurveyInstance = surveyService.getSurveyInstance(
        surveyInstance.getId());

    compareSurveyInstances(surveyInstance, retrievedSurveyInstance);

    SurveyResponse surveyResponse = new SurveyResponse(surveyInstance);

    surveyService.saveSurveyResponse(surveyResponse);

    SurveyResponse retrievedSurveyResponse = surveyService.getSurveyResponse(
        surveyResponse.getId());

    compareSurveyResponses(surveyResponse, retrievedSurveyResponse);
  }


  /**
   * Test the save survey response functionality.
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

  private static synchronized SurveyInstance getCTOValuesSurveyInstance(
    SurveyDefinition surveyDefinition)
  {
    SurveyInstance surveyInstance = new SurveyInstance(UUID.randomUUID(), "CTO ELT Values Survey - September 2016",
      surveyDefinition);

    return surveyInstance;
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
    assertEquals(
      "The rating values for the two survey group rating item responses do not match",
      surveyGroupRatingItemResponse1.getRating(),
      surveyGroupRatingItemResponse2.getRating());
  }

  private void compareSurveyInstances(SurveyInstance surveyInstance1,
      SurveyInstance surveyInstance2)
  {
    assertEquals("The ID values for the two survey instances do not match",
        surveyInstance1.getId(), surveyInstance2.getId());
    assertEquals("The name values for the two survey instances do not match",
        surveyInstance1.getName(), surveyInstance2.getName());
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
