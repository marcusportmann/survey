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
import guru.mmp.application.web.template.components.InputPanel;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.form.ChoiceRenderer;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.PropertyModel;

import java.util.ArrayList;
import java.util.List;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyResponseInputPanel</code> class.
 *
 * @author Marcus Portmann
 */
public class SurveyResponseInputPanel extends InputPanel
{
  private static final long serialVersionUID = 1000000;

  /**
   * Constructs a new <code>SurveyResponseInputPanel</code>.
   *
   * @param id                  the non-null id of this component
   * @param surveyResponseModel the model for the survey response
   */
  public SurveyResponseInputPanel(String id, IModel<SurveyResponse> surveyResponseModel)
  {
    super(id, surveyResponseModel);

    SurveyResponse surveyResponse = surveyResponseModel.getObject();

    SurveyDefinition surveyDefinition = surveyResponse.getInstance().getDefinition();

    add(new ListView<SurveyGroupRatingsDefinition>("groupRatingsDefinition",
        surveyDefinition.getGroupRatingsDefinitions())
        {
          @Override
          protected void populateItem(ListItem<SurveyGroupRatingsDefinition> item)
          {
            SurveyGroupRatingsDefinition groupRatingsDefinition = item.getModelObject();

            List<SurveyGroupRatingDefinition> groupRatingDefinitions =
                groupRatingsDefinition.getGroupRatingDefinitions();

            item.add(new ListView<SurveyGroupRatingDefinition>("groupRatingDefinition",
                groupRatingDefinitions)
            {
              @Override
              protected void populateItem(ListItem<SurveyGroupRatingDefinition> item)
              {
                SurveyGroupRatingDefinition groupRatingDefinition = item.getModelObject();

                item.add(new Label("name", groupRatingDefinition.getName()));
              }
            });

            item.add(new ListView<SurveyGroupMemberDefinition>("groupMemberDefinition",
                surveyDefinition.getGroupDefinition(groupRatingsDefinition.getGroupDefinitionId())
                .getGroupMemberDefinitions())
            {
              @Override
              protected void populateItem(ListItem<SurveyGroupMemberDefinition> item)
              {
                SurveyGroupMemberDefinition groupMemberDefinition = item.getModelObject();

                item.add(new Label("name", groupMemberDefinition.getName()));

                item.add(new ListView<SurveyGroupRatingDefinition>("groupRatingResponse",
                    groupRatingDefinitions)
                {
                  @Override
                  protected void populateItem(ListItem<SurveyGroupRatingDefinition> item)
                  {
                    SurveyGroupRatingDefinition groupRatingDefinition = item.getModelObject();

                    if (groupRatingDefinition.getRatingType() == SurveyGroupRatingType.YES_NO_NA)
                    {
                      SurveyGroupRatingResponse groupRatingResponse =
                          surveyResponse.getGroupRatingResponse(groupRatingsDefinition.getId(),
                          groupRatingDefinition.getId(), groupMemberDefinition.getId());

                      ChoiceRenderer<StringSelectOption> choiceRenderer = new ChoiceRenderer<>(
                          "name", "value");

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
