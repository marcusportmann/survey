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
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;

import java.util.List;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyDefinitionInputPanel</code> class.
 *
 * @author Marcus Portmann
 */
public class SurveyDefinitionInputPanel extends InputPanel
{
  private static final long serialVersionUID = 1000000;

  /**
   * Constructs a new <code>SurveyDefinitionInputPanel</code>.
   *
   * @param id                    the non-null id of this component
   * @param surveyDefinitionModel the model for the survey response
   */
  public SurveyDefinitionInputPanel(String id, IModel<SurveyDefinition> surveyDefinitionModel)
  {
    super(id, surveyDefinitionModel);

    SurveyDefinition surveyDefinition = surveyDefinitionModel.getObject();

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
          }
        });

      }
    });
  }
}
