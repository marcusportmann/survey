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
   * Test the remove survey template group member functionality.
   */
  @Test
  public void removeSurveyTemplateGroupMemberTest()
    throws Exception
  {
    SurveyTemplate surveyTemplate = getTestSurveyTemplate();

    surveyService.saveSurveyTemplate(surveyTemplate);

    surveyTemplate = surveyService.getSurveyTemplate(surveyTemplate.getId());

    SurveyTemplateGroup firstSurveyTemplateGroup = surveyTemplate.getGroups().iterator().next();

    firstSurveyTemplateGroup.removeMember(firstSurveyTemplateGroup.getMembers().get(0).getId());

    surveyService.saveSurveyTemplate(surveyTemplate);

    SurveyTemplate retrievedSurveyTemplate = surveyService.getSurveyTemplate(
        surveyTemplate.getId());

    compareSurveyTemplates(surveyTemplate, retrievedSurveyTemplate);
  }

  /**
   * Test the remove survey template group rating item functionality.
   */
  @Test
  public void removeSurveyTemplateGroupRatingItem()
    throws Exception
  {
    SurveyTemplate surveyTemplate = getTestSurveyTemplate();

    surveyService.saveSurveyTemplate(surveyTemplate);

    surveyTemplate = surveyService.getSurveyTemplate(surveyTemplate.getId());

    surveyTemplate.getGroupRatingItems().remove(surveyTemplate.getGroupRatingItems().iterator()
        .next());

    surveyService.saveSurveyTemplate(surveyTemplate);

    SurveyTemplate retrievedSurveyTemplate = surveyService.getSurveyTemplate(
        surveyTemplate.getId());

    compareSurveyTemplates(surveyTemplate, retrievedSurveyTemplate);
  }

  /**
   * Test the remove survey template group functionality.
   */
  @Test
  public void removeSurveyTemplateGroupTest()
    throws Exception
  {
    SurveyTemplate surveyTemplate = getTestSurveyTemplate();

    surveyService.saveSurveyTemplate(surveyTemplate);

    surveyTemplate = surveyService.getSurveyTemplate(surveyTemplate.getId());

    SurveyTemplateGroup firstSurveyTemplateGroup = surveyTemplate.getGroups().iterator().next();

    surveyTemplate.removeGroup(firstSurveyTemplateGroup.getId());

    surveyService.saveSurveyTemplate(surveyTemplate);

    SurveyTemplate retrievedSurveyTemplate = surveyService.getSurveyTemplate(
        surveyTemplate.getId());

    compareSurveyTemplates(surveyTemplate, retrievedSurveyTemplate);
  }

  /**
   * Test the save new survey template functionality.
   */
  @Test
  public void saveNewSurveyTemplateTest()
    throws Exception
  {
    SurveyTemplate surveyTemplate = getTestSurveyTemplate();

    surveyService.saveSurveyTemplate(surveyTemplate);

    SurveyTemplate retrievedSurveyTemplate = surveyService.getSurveyTemplate(
        surveyTemplate.getId());

    compareSurveyTemplates(surveyTemplate, retrievedSurveyTemplate);
  }

  /**
   * Test the save updated survey template functionality.
   */
  @Test
  public void saveUpdatedSurveyTemplateTest()
    throws Exception
  {
    SurveyTemplate surveyTemplate = getTestSurveyTemplate();

    surveyService.saveSurveyTemplate(surveyTemplate);

    surveyTemplate = surveyService.getSurveyTemplate(surveyTemplate.getId());

    surveyTemplate.setName(surveyTemplate.getName() + " Updated");
    surveyTemplate.setDescription(surveyTemplate.getDescription() + " Updated");

    surveyService.saveSurveyTemplate(surveyTemplate);

    SurveyTemplate retrievedSurveyTemplate = surveyService.getSurveyTemplate(
        surveyTemplate.getId());

    compareSurveyTemplates(surveyTemplate, retrievedSurveyTemplate);
  }

  private static synchronized SurveyTemplate getTestSurveyTemplate()
  {
    SurveyTemplate surveyTemplate = new SurveyTemplate(UUID.randomUUID(),
        "Test Survey Template Name", "Test Survey Template Description");

    SurveyTemplateGroup surveyTemplateGroup = new SurveyTemplateGroup(UUID.randomUUID(),
        "Test Survey Template Group Name", "Test Survey Template Group Description");

    surveyTemplateGroup.addMember(new SurveyTemplateGroupMember(UUID.randomUUID(),
        "Test Survey Template Group Member 1"));
    surveyTemplateGroup.addMember(new SurveyTemplateGroupMember(UUID.randomUUID(),
        "Test Survey Template Group Member 2"));
    surveyTemplateGroup.addMember(new SurveyTemplateGroupMember(UUID.randomUUID(),
        "Test Survey Template Group Member 4"));
    surveyTemplateGroup.addMember(new SurveyTemplateGroupMember(UUID.randomUUID(),
        "Test Survey Template Group Member 3"));

    surveyTemplate.addGroup(surveyTemplateGroup);

    surveyTemplate.addGroupRatingItem(new SurveyTemplateGroupRatingItem(UUID.randomUUID(),
        "Test Survey Template Group Rating Item 1", surveyTemplateGroup,
        SurveyTemplateGroupRatingType.YES_NO_NA));
    surveyTemplate.addGroupRatingItem(new SurveyTemplateGroupRatingItem(UUID.randomUUID(),
        "Test Survey Template Group Rating Item 2", surveyTemplateGroup,
        SurveyTemplateGroupRatingType.YES_NO_NA));

    surveyTemplate.addGroupRatingItem(new SurveyTemplateGroupRatingItem(UUID.randomUUID(),
        "Test Survey Template Group Rating Item 3", surveyTemplateGroup,
        SurveyTemplateGroupRatingType.YES_NO_NA));

    return surveyTemplate;
  }

  private void compareSurveyTemplateGroupMembers(
      SurveyTemplateGroupMember surveyTemplateGroupMember1,
      SurveyTemplateGroupMember surveyTemplateGroupMember2)
  {
    assertEquals("The ID values for the two survey template group members do not match",
        surveyTemplateGroupMember1.getId(), surveyTemplateGroupMember2.getId());
    assertEquals("The name values for the two survey template group members do not match",
        surveyTemplateGroupMember1.getName(), surveyTemplateGroupMember2.getName());
  }

  private void compareSurveyTemplateGroupRatingItems(
      SurveyTemplateGroupRatingItem surveyTemplateGroupRatingItem1,
      SurveyTemplateGroupRatingItem surveyTemplateGroupRatingItem2)
  {
    assertEquals("The ID values for the two survey template group rating items do not match",
        surveyTemplateGroupRatingItem1.getId(), surveyTemplateGroupRatingItem2.getId());
    assertEquals("The name values for the two survey template group rating items do not match",
        surveyTemplateGroupRatingItem1.getName(), surveyTemplateGroupRatingItem2.getName());
    assertEquals(
        "The rating type values for the two survey template group rating items do not match",
        surveyTemplateGroupRatingItem1.getRatingType(),
        surveyTemplateGroupRatingItem2.getRatingType());

  }

  private void compareSurveyTemplateGroups(SurveyTemplateGroup surveyTemplateGroup1,
      SurveyTemplateGroup surveyTemplateGroup2)
  {
    assertEquals("The ID values for the two survey template groups do not match",
        surveyTemplateGroup1.getId(), surveyTemplateGroup2.getId());
    assertEquals("The name values for the two survey template groups do not match",
        surveyTemplateGroup1.getName(), surveyTemplateGroup2.getName());
    assertEquals("The description values for the two survey template groups do not match",
        surveyTemplateGroup1.getDescription(), surveyTemplateGroup2.getDescription());
    assertEquals(
        "The survey template group members for the two survey template groups do not match",
        surveyTemplateGroup1.getMembers().size(), surveyTemplateGroup2.getMembers().size());

    for (SurveyTemplateGroupMember member1 : surveyTemplateGroup1.getMembers())
    {
      SurveyTemplateGroupMember member2 = surveyTemplateGroup2.getMember(member1.getId());

      assertNotNull("The survey template group member could not be found", member2);

      compareSurveyTemplateGroupMembers(member1, member2);
    }
  }

  private void compareSurveyTemplates(SurveyTemplate surveyTemplate1,
      SurveyTemplate surveyTemplate2)
  {
    assertEquals("The ID values for the two survey templates do not match",
        surveyTemplate1.getId(), surveyTemplate2.getId());
    assertEquals("The name values for the two survey templates do not match",
        surveyTemplate1.getName(), surveyTemplate2.getName());
    assertEquals("The description values for the two survey templates do not match",
        surveyTemplate1.getDescription(), surveyTemplate2.getDescription());
    assertEquals("The survey template groups for the two survey templates do not match",
        surveyTemplate1.getGroups().size(), surveyTemplate2.getGroups().size());

    for (SurveyTemplateGroup group1 : surveyTemplate1.getGroups())
    {
      SurveyTemplateGroup group2 = surveyTemplate2.getGroup(group1.getId());

      assertNotNull("The survey template group could not be found", group2);

      compareSurveyTemplateGroups(group1, group2);
    }

    assertEquals(
        "The survey template group rating items for the two survey templates do not match",
        surveyTemplate1.getGroupRatingItems().size(), surveyTemplate2.getGroupRatingItems().size());

    for (SurveyTemplateGroupRatingItem groupRatingItem1 : surveyTemplate1.getGroupRatingItems())
    {
      SurveyTemplateGroupRatingItem groupRatingItem2 = surveyTemplate2.getGroupRatingItem(
          groupRatingItem1.getId());

      assertNotNull("The survey template group rating item could not be found", groupRatingItem2);

      compareSurveyTemplateGroupRatingItems(groupRatingItem1, groupRatingItem2);
    }
  }
}
