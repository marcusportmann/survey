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

package digital.survey.web.components;

//~--- non-JDK imports --------------------------------------------------------

import digital.survey.model.*;
import guru.mmp.application.web.components.StringSelectOption;
import guru.mmp.application.web.template.components.DropDownChoiceWithFeedback;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.form.ChoiceRenderer;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.markup.html.panel.Panel;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.PropertyModel;

import java.util.ArrayList;
import java.util.List;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyGroupRatingsResponsePanel</code> class.
 *
 * @author Marcus Portmann
 */
class SurveyGroupRatingsResponsePanel extends Panel
{
  private static final long serialVersionUID = 1000000;

  /**
   * Constructs a new <code>SurveyGroupRatingsResponsePanel</code>.
   *
   * @param id                          the non-null id of this component
   * @param groupRatingsDefinitionModel the model for the survey group ratings definition
   * @param groupDefinitionModel        the model for the survey group definition
   * @param surveyResponseModel         the model for the survey response
   */
  SurveyGroupRatingsResponsePanel(String id,
      IModel<SurveyGroupRatingsDefinition> groupRatingsDefinitionModel,
      IModel<SurveyGroupDefinition> groupDefinitionModel,
      IModel<SurveyResponse> surveyResponseModel)
  {
    super(id);

    add(new ListView<SurveyGroupRatingDefinition>("groupRating", new PropertyModel<>(
        groupRatingsDefinitionModel, "groupRatingDefinitions"))
        {
          @Override
          protected void populateItem(ListItem<SurveyGroupRatingDefinition> item)
          {
            item.add(new Label("name", new PropertyModel(item.getModel(), "name")));
          }
        });

    add(new ListView<SurveyGroupMemberDefinition>("groupMember", new PropertyModel<>(
        groupDefinitionModel, "groupMemberDefinitions"))
        {
          @Override
          protected void populateItem(ListItem<SurveyGroupMemberDefinition> item)
          {
            SurveyGroupMemberDefinition groupMemberDefinition = item.getModelObject();

            item.add(new Label("name", new PropertyModel<>(groupMemberDefinition, "name")));

            item.add(new ListView<SurveyGroupRatingDefinition>("groupRatingResponse",
                new PropertyModel<>(groupRatingsDefinitionModel, "groupRatingDefinitions"))
            {
              @Override
              protected void populateItem(ListItem<SurveyGroupRatingDefinition> item)
              {
                SurveyGroupRatingDefinition groupRatingDefinition = item.getModelObject();

                SurveyGroupRatingsDefinition groupRatingsDefinition =
                    groupRatingsDefinitionModel.getObject();

                SurveyResponse surveyResponse = surveyResponseModel.getObject();

                if (groupRatingDefinition.getRatingType() == SurveyGroupRatingType.YES_NO_NA)
                {
                  SurveyGroupRatingResponse groupRatingResponse =
                      surveyResponse.getGroupRatingResponse(groupRatingsDefinition.getId(),
                      groupRatingDefinition.getId(), groupMemberDefinition.getId());

                  ChoiceRenderer<StringSelectOption> choiceRenderer = new ChoiceRenderer<>("name",
                      "value");

                  item.add(new DropDownChoiceWithFeedback<>("rating", new PropertyModel<>(
                      groupRatingResponse, "rating"), getGroupRatingResponseOptions(
                      groupRatingDefinition.getRatingType()), choiceRenderer));
                }
                else
                {
                  throw new RuntimeException("Unsupported survey group rating item type ("
                      + groupRatingDefinition.getRatingType() + ")");
                }
              }
            });
          }
        });
  }

  private List<StringSelectOption> getGroupRatingResponseOptions(
      SurveyGroupRatingType groupRatingType)
  {
    List<StringSelectOption> options = new ArrayList<>();

    if (groupRatingType == SurveyGroupRatingType.YES_NO_NA)
    {
      options.add(new StringSelectOption("Yes", "1"));
      options.add(new StringSelectOption("No", "0"));
      options.add(new StringSelectOption("-", "-1"));
    }

    return options;
  }
}
