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
import guru.mmp.application.web.template.components.InputPanel;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.model.IModel;

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

    add(new ListView<SurveyItemDefinition>("itemDefinition", surveyDefinition.getItemDefinitions())
        {
          @Override
          protected void populateItem(ListItem<SurveyItemDefinition> item)
          {
            SurveyItemDefinition itemDefinition = item.getModelObject();

            if (itemDefinition instanceof SurveyGroupRatingsDefinition)
            {
              item.add(new SurveyGroupRatingsDefinitionInputPanel("itemDefinitionPanel",
                  (SurveyGroupRatingsDefinition) itemDefinition, surveyDefinitionModel));
            }
          }
        });
  }
}
