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

import digital.survey.model.SurveyDefinition;
import digital.survey.model.SurveyGroupMemberDefinition;
import digital.survey.model.SurveyGroupRatingDefinition;
import digital.survey.model.SurveyGroupRatingsDefinition;
import guru.mmp.application.web.template.components.InputPanel;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.model.IModel;

import java.util.List;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyGroupRatingsDefinitionInputPanel</code> class.
 *
 * @author Marcus Portmann
 */
public class SurveyGroupRatingsDefinitionInputPanel extends InputPanel
{
  private static final long serialVersionUID = 1000000;

  /**
   * Constructs a new <code>SurveyGroupRatingsDefinitionInputPanel</code>.
   *
   * @param id                     the non-null id of this component
   * @param groupRatingsDefinition the survey group ratings definition
   * @param surveyDefinitionModel  the model for the survey response
   */
  public SurveyGroupRatingsDefinitionInputPanel(String id,
      SurveyGroupRatingsDefinition groupRatingsDefinition,
      IModel<SurveyDefinition> surveyDefinitionModel)
  {
    super(id);

    SurveyDefinition surveyDefinition = surveyDefinitionModel.getObject();

    List<SurveyGroupRatingDefinition> groupRatingDefinitions =
        groupRatingsDefinition.getGroupRatingDefinitions();

    add(new ListView<SurveyGroupRatingDefinition>("groupRatingDefinition", groupRatingDefinitions)
        {
          @Override
          protected void populateItem(ListItem<SurveyGroupRatingDefinition> item)
          {
            SurveyGroupRatingDefinition groupRatingDefinition = item.getModelObject();

            item.add(new Label("name", groupRatingDefinition.getName()));
          }
        });

    add(new ListView<SurveyGroupMemberDefinition>("groupMemberDefinition",
        surveyDefinition.getGroupDefinition(groupRatingsDefinition.getGroupDefinitionId())
        .getGroupMemberDefinitions())
        {
          @Override
          protected void populateItem(ListItem<SurveyGroupMemberDefinition> item)
          {
            SurveyGroupMemberDefinition groupMemberDefinition = item.getModelObject();

            item.add(new Label("name", groupMemberDefinition.getName()));
          }
        });
  }
}
