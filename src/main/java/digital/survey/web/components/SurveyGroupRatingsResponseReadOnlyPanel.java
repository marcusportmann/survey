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
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.markup.html.panel.Panel;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;

/**
 * The <code>SurveyGroupRatingsResponseReadOnlyPanel</code> class.
 *
 * @author Marcus Portmann
 */
class SurveyGroupRatingsResponseReadOnlyPanel extends Panel
{
  /**
   * Constructs a new <code>SurveyGroupRatingsResponseReadOnlyPanel</code>.
   *
   * @param id                                the non-null id of this component
   * @param surveyGroupRatingsDefinitionModel the model for the survey group ratings definition
   * @param surveyGroupDefinitionModel        the model for the survey group definition
   * @param surveyResponseModel               the model for the survey response
   */
  SurveyGroupRatingsResponseReadOnlyPanel(String id,
      IModel<SurveyGroupRatingsDefinition> surveyGroupRatingsDefinitionModel,
      IModel<SurveyGroupDefinition> surveyGroupDefinitionModel,
      IModel<SurveyResponse> surveyResponseModel)
  {
    super(id);

    add(new ListView<SurveyGroupRatingDefinition>("groupRating", new PropertyModel<>(
        surveyGroupRatingsDefinitionModel, "groupRatingDefinitions"))
        {
          @Override
          protected void populateItem(ListItem<SurveyGroupRatingDefinition> item)
          {
            item.add(new Label("name", new PropertyModel(item.getModel(), "name")));
          }
        });

    add(new ListView<SurveyGroupMemberDefinition>("groupMember", new PropertyModel<>(
        surveyGroupDefinitionModel, "groupMemberDefinitions"))
        {
          @Override
          protected void populateItem(ListItem<SurveyGroupMemberDefinition> item)
          {
            SurveyGroupMemberDefinition groupMemberDefinition = item.getModelObject();

            item.add(new Label("name", new PropertyModel<>(groupMemberDefinition, "name")));

            item.add(new ListView<SurveyGroupRatingDefinition>("groupRatingResponse",
                new PropertyModel<>(surveyGroupRatingsDefinitionModel, "groupRatingDefinitions"))
            {
              @Override
              protected void populateItem(ListItem<SurveyGroupRatingDefinition> item)
              {
                SurveyGroupRatingDefinition groupRatingDefinition = item.getModelObject();

                SurveyGroupRatingsDefinition groupRatingsDefinition =
                    surveyGroupRatingsDefinitionModel.getObject();

                SurveyResponse surveyResponse = surveyResponseModel.getObject();

                if (groupRatingDefinition.getRatingType() == SurveyGroupRatingType.YES_NO_NA)
                {
                  SurveyGroupRatingResponse groupRatingResponse =
                      surveyResponse.getGroupRatingResponseForDefinition(groupRatingsDefinition.getId(),
                      groupRatingDefinition.getId(), groupMemberDefinition.getId());

                  item.add(new YesNoNaRatingLabel("rating", new Model<>(YesNoNaRating.fromCode(
                      groupRatingResponse.getRating()))));
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
}
