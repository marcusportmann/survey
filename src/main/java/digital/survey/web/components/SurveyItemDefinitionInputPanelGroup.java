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
import digital.survey.model.SurveyGroupRatingsDefinition;
import digital.survey.model.SurveyItemDefinition;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.Model;

import java.util.List;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <class>SurveyItemDefinitionInputPanelGroup</class>.
 *
 * @author Marcus Portmann
 */
public class SurveyItemDefinitionInputPanelGroup extends WebMarkupContainer
{
  /**
   * Constructs a new <code>SurveyItemDefinitionInputPanelGroup</code>.
   *
   * @param id                         the non-null id of this component
   * @param surveyDefinitionModel      the model for the survey definition
   * @param surveyItemDefinitionsModel the model for the survey item definitions
   */
  public SurveyItemDefinitionInputPanelGroup(String id,
      IModel<SurveyDefinition> surveyDefinitionModel,
      IModel<List<SurveyItemDefinition>> surveyItemDefinitionsModel)
  {
    super(id);

    setOutputMarkupId(true);

    add(new ListView<SurveyItemDefinition>("itemDefinition", surveyItemDefinitionsModel)
        {
          @Override
          protected void populateItem(ListItem<SurveyItemDefinition> item)
          {
            item.setRenderBodyOnly(true);

            SurveyItemDefinition itemDefinition = item.getModelObject();

            if (itemDefinition instanceof SurveyGroupRatingsDefinition)
            {
              SurveyGroupRatingsDefinition groupRatingsDefinition =
                  (SurveyGroupRatingsDefinition) itemDefinition;

              item.add(new SurveyGroupRatingsDefinitionInputPanel("itemDefinitionPanel",
                  surveyDefinitionModel, new Model<>(groupRatingsDefinition), new Model<>(
                  surveyDefinitionModel.getObject().getGroupDefinition(
                  groupRatingsDefinition.getGroupDefinitionId()))));
            }
          }
        });
  }
}
