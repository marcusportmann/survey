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
import guru.mmp.application.web.template.components.InputPanel;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.model.IModel;

import java.util.ArrayList;
import java.util.List;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyResultPanel</code> class.
 *
 * @author Marcus Portmann
 */
public class SurveyResultPanel extends InputPanel
{
  private static final long serialVersionUID = 1000000;

  /**
   * Constructs a new <code>SurveyResultPanel</code>.
   *
   * @param id                the non-null id of this component
   * @param surveyResultModel the model for the survey result
   */
  public SurveyResultPanel(String id, IModel<SurveyResult> surveyResultModel)
  {
    super(id, surveyResultModel);

    SurveyResult surveyResult = surveyResultModel.getObject();

    SurveyDefinition surveyDefinition = surveyResult.getInstance().getDefinition();

    add(new ListView<SurveyGroupDefinition>("groupDefinition",
        surveyDefinition.getGroupDefinitions())
        {
          @Override
          protected void populateItem(ListItem<SurveyGroupDefinition> item)
          {
            SurveyGroupDefinition groupDefinition = item.getModelObject();

            List<SurveyGroupRatingItemDefinition> groupRatingItemDefinitions =
                surveyDefinition.getGroupRatingItemDefinitionsForGroupDefinition(
                groupDefinition.getId());

            item.add(new ListView<SurveyGroupRatingItemDefinition>("groupRatingItemDefinition",
                groupRatingItemDefinitions)
            {
              @Override
              protected void populateItem(ListItem<SurveyGroupRatingItemDefinition> item)
              {
                SurveyGroupRatingItemDefinition groupRatingItemDefinition = item.getModelObject();

                item.add(new Label("name", groupRatingItemDefinition.getName()));
              }
            });

            item.add(new ListView<SurveyGroupMemberDefinition>("groupMemberDefinition",
                groupDefinition.getGroupMemberDefinitions())
            {
              @Override
              protected void populateItem(ListItem<SurveyGroupMemberDefinition> item)
              {
                SurveyGroupMemberDefinition groupMemberDefinition = item.getModelObject();

                item.add(new Label("name", groupMemberDefinition.getName()));

                List<SurveyGroupRatingItemResult> groupRatingItemResults = new ArrayList<>();

                for (SurveyGroupRatingItemDefinition groupRatingItemDefinition :
                    groupRatingItemDefinitions)
                {
                  groupRatingItemResults.add(surveyResult.getGroupRatingItemResult(
                      groupRatingItemDefinition.getId(), groupMemberDefinition.getId()));
                }

                item.add(new ListView<SurveyGroupRatingItemResult>("groupRatingItemResult",
                    groupRatingItemResults)
                {
                  @Override
                  protected void populateItem(ListItem<SurveyGroupRatingItemResult> item)
                  {
                    SurveyGroupRatingItemResult groupRatingItemResult = item.getModelObject();

                    if (groupRatingItemResult.getGroupRatingItemDefinitionRatingType().equals(
                        SurveyGroupRatingItemType.YES_NO_NA))
                    {
                      double averageRating = groupRatingItemResult.getAverageRating();

                      if (averageRating == -1)
                      {
                        item.add(new Label("rating", "-"));
                        item.add(new Label("numberOfResults", ""));
                      }
                      else
                      {
                        item.add(new Label("rating", String.format("%3.0f%%", averageRating)));
                        item.add(new Label("numberOfResults", String.format("(%d)", groupRatingItemResult.getRatings().size())));
                      }
                    }
                    else
                    {
                      throw new RuntimeException("Unsupported survey group rating item type ("
                          + groupRatingItemResult.getGroupRatingItemDefinitionRatingType() + ")");
                    }
                  }
                });
              }
            });
          }
        });
  }
}
