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
   * Test the remove survey group definition member functionality.
   */
  @Test
  public void removeSurveyGroupDefinitionMemberTest()
    throws Exception
  {
    SurveyDefinition surveyDefinition = getTestSurveyDefinition();

    surveyService.saveSurveyDefinition(surveyDefinition);

    surveyDefinition = surveyService.getSurveyDefinition(surveyDefinition.getId(), 1);

    SurveyGroupDefinition firstSurveyGroupDefinition = surveyDefinition.getSurveyGroupDefinitions().iterator().next();

    firstSurveyGroupDefinition.removeSurveyGroupMemberDefinition(firstSurveyGroupDefinition.getSurveyGroupMemberDefinitions().get(0).getId());

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

    surveyDefinition.getSurveyGroupRatingItemDefinitions().remove(surveyDefinition.getSurveyGroupRatingItemDefinitions().iterator()
        .next());

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

    SurveyGroupDefinition firstSurveyGroupDefinition = surveyDefinition.getSurveyGroupDefinitions().iterator().next();

    surveyDefinition.removeSurveyGroupDefinition(firstSurveyGroupDefinition.getId());

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

  private static synchronized SurveyDefinition getTestSurveyDefinition()
  {
    SurveyDefinition surveyDefinition = new SurveyDefinition(UUID.randomUUID(), 1,
        "Test Survey Template Name", "Test Survey Template Description");

    SurveyGroupDefinition surveyDefinitionGroup = new SurveyGroupDefinition(UUID.randomUUID(), 1,
        "Test Survey Group Definition Name", "Test Survey Group Definition Description");

    surveyDefinitionGroup.addSurveyGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.randomUUID(), 1,
        "Test Survey Group Definition Member 1"));
    surveyDefinitionGroup.addSurveyGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.randomUUID(), 1,
        "Test Survey Group Definition Member 2"));
    surveyDefinitionGroup.addSurveyGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.randomUUID(), 1,
        "Test Survey Group Definition Member 4"));
    surveyDefinitionGroup.addSurveyGroupMemberDefinition(new SurveyGroupMemberDefinition(UUID.randomUUID(), 1,
        "Test Survey Group Definition Member 3"));

    surveyDefinition.addSurveyGroupDefinition(surveyDefinitionGroup);

    surveyDefinition.addSurveyGroupRatingItemDefinition(new SurveyGroupRatingItemDefinition(UUID.randomUUID(), 1,
        "Test Survey Group Definition Rating Item 1", surveyDefinitionGroup,
      SurveyGroupRatingItemType.YES_NO_NA));
    surveyDefinition.addSurveyGroupRatingItemDefinition(new SurveyGroupRatingItemDefinition(UUID.randomUUID(), 1,
        "Test Survey Group Definition Rating Item 2", surveyDefinitionGroup,
      SurveyGroupRatingItemType.YES_NO_NA));

    surveyDefinition.addSurveyGroupRatingItemDefinition(new SurveyGroupRatingItemDefinition(UUID.randomUUID(), 1,
        "Test Survey Group Definition Rating Item 3", surveyDefinitionGroup,
      SurveyGroupRatingItemType.YES_NO_NA));

    return surveyDefinition;
  }

  private void compareSurveyGroupMemberDefinitions(
      SurveyGroupMemberDefinition surveyGroupMemberDefinition1,
      SurveyGroupMemberDefinition surveyGroupMemberDefinition2)
  {
    assertEquals("The ID values for the two survey group definition members do not match",
        surveyGroupMemberDefinition1.getId(), surveyGroupMemberDefinition2.getId());
    assertEquals("The name values for the two survey group definition members do not match",
        surveyGroupMemberDefinition1.getName(), surveyGroupMemberDefinition2.getName());
  }

  private void compareSurveyGroupRatingItemDefinitions(
      SurveyGroupRatingItemDefinition surveyDefinitionGroupRatingItem1,
      SurveyGroupRatingItemDefinition surveyDefinitionGroupRatingItem2)
  {
    assertEquals("The ID values for the two survey group rating item definitions do not match",
        surveyDefinitionGroupRatingItem1.getId(), surveyDefinitionGroupRatingItem2.getId());
    assertEquals("The name values for the two survey group rating item definitions do not match",
        surveyDefinitionGroupRatingItem1.getName(), surveyDefinitionGroupRatingItem2.getName());
    assertEquals(
        "The rating type values for the two survey group rating item definitions do not match",
        surveyDefinitionGroupRatingItem1.getRatingType(),
        surveyDefinitionGroupRatingItem2.getRatingType());

  }

  private void compareSurveyGroupDefinitions(SurveyGroupDefinition surveyDefinitionGroup1,
      SurveyGroupDefinition surveyDefinitionGroup2)
  {
    assertEquals("The ID values for the two survey group definitions do not match",
        surveyDefinitionGroup1.getId(), surveyDefinitionGroup2.getId());
    assertEquals("The name values for the two survey group definitions do not match",
        surveyDefinitionGroup1.getName(), surveyDefinitionGroup2.getName());
    assertEquals("The description values for the two survey group definitions do not match",
        surveyDefinitionGroup1.getDescription(), surveyDefinitionGroup2.getDescription());
    assertEquals(
        "The survey group definition members for the two survey group definitions do not match",
        surveyDefinitionGroup1.getSurveyGroupMemberDefinitions().size(), surveyDefinitionGroup2.getSurveyGroupMemberDefinitions().size());

    for (SurveyGroupMemberDefinition member1 : surveyDefinitionGroup1.getSurveyGroupMemberDefinitions())
    {
      SurveyGroupMemberDefinition member2 = surveyDefinitionGroup2.getSurveyGroupMemberDefinition(member1.getId());

      assertNotNull("The survey group definition member could not be found", member2);

      compareSurveyGroupMemberDefinitions(member1, member2);
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
    assertEquals("The survey group definitions for the two survey definitions do not match",
        surveyDefinition1.getSurveyGroupDefinitions().size(), surveyDefinition2.getSurveyGroupDefinitions().size());

    for (SurveyGroupDefinition group1 : surveyDefinition1.getSurveyGroupDefinitions())
    {
      SurveyGroupDefinition group2 = surveyDefinition2.getSurveyGroupDefinition(group1.getId());

      assertNotNull("The survey group definition could not be found", group2);

      compareSurveyGroupDefinitions(group1, group2);
    }

    assertEquals(
        "The survey group rating item definitions for the two survey definitions do not match",
        surveyDefinition1.getSurveyGroupRatingItemDefinitions().size(), surveyDefinition2.getSurveyGroupRatingItemDefinitions().size());

    for (SurveyGroupRatingItemDefinition groupRatingItem1 : surveyDefinition1.getSurveyGroupRatingItemDefinitions())
    {
      SurveyGroupRatingItemDefinition groupRatingItem2 = surveyDefinition2.getSurveyGroupRatingItemDefinition(
          groupRatingItem1.getId());

      assertNotNull("The survey group rating item definition could not be found", groupRatingItem2);

      compareSurveyGroupRatingItemDefinitions(groupRatingItem1, groupRatingItem2);
    }
  }
}
