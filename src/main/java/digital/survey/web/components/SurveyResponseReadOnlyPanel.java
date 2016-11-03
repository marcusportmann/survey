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
import org.apache.wicket.model.Model;

import java.util.ArrayList;
import java.util.List;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyResponseReadOnlyPanel</code> class.
 *
 * @author Marcus Portmann
 */
public class SurveyResponseReadOnlyPanel extends InputPanel
{
  private static final long serialVersionUID = 1000000;

  /**
   * Constructs a new <code>SurveyResponseReadOnlyPanel</code>.
   *
   * @param id                  the non-null id of this component
   * @param surveyResponseModel the model for the survey response
   */
  public SurveyResponseReadOnlyPanel(String id, IModel<SurveyResponse> surveyResponseModel)
  {
    super(id, surveyResponseModel);

    SurveyResponse surveyResponse = surveyResponseModel.getObject();

    SurveyDefinition surveyDefinition = surveyResponse.getInstance().getDefinition();

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

                List<SurveyGroupRatingItemDefinition> groupRatingItemDefinitions =
                    surveyDefinition.getGroupRatingItemDefinitionsForGroupDefinition(
                    groupDefinition.getId());

                item.add(new ListView<SurveyGroupRatingItemDefinition>("groupRatingItemResponse",
                    groupRatingItemDefinitions)
                {
                  @Override
                  protected void populateItem(ListItem<SurveyGroupRatingItemDefinition> item)
                  {
                    SurveyGroupRatingItemDefinition groupRatingItemDefinition =
                        item.getModelObject();

                    if (groupRatingItemDefinition.getRatingType() == SurveyGroupRatingItemType
                        .YES_NO_NA)
                    {
                      SurveyGroupRatingItemResponse groupRatingItemResponse =
                          surveyResponse.getGroupRatingItemResponse(
                          groupRatingItemDefinition.getId(), groupMemberDefinition.getId());

                      item.add(new YesNoNaRatingLabel("rating", new Model<YesNoNaRating>(
                          YesNoNaRating.fromCode(groupRatingItemResponse.getRating()))));
                    }
                    else
                    {
                      throw new RuntimeException("Unsupported survey group rating item type ("
                          + groupRatingItemDefinition.getRatingType() + ")");
                    }
                  }
                });
              }
            });
          }
        });
  }
}
