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
import digital.survey.model.SurveySectionDefinition;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.PropertyModel;

/**
 * The <code>SurveySectionDefinitionPanel</code> class.
 *
 * @author Marcus Portmann
 */
public class SurveySectionDefinitionPanel extends SurveyItemDefinitionPanel
{
  private static final long serialVersionUID = 1000000;

  /**
   * Constructs a new <code>SurveySectionDefinitionPanel</code>.
   *
   * @param id                           the non-null id of this component
   * @param surveyDefinitionModel        the model for the survey definition
   * @param surveySectionDefinitionModel the model for the survey group ratings definition
   */
  public SurveySectionDefinitionPanel(String id, IModel<SurveyDefinition> surveyDefinitionModel,
      IModel<SurveySectionDefinition> surveySectionDefinitionModel)
  {
    super(id, surveyDefinitionModel, surveySectionDefinitionModel, "fa-bars", true);

    getBodyContainer().add(new SurveyItemDefinitionPanelGroup("itemDefinitionPanelGroup",
        surveyDefinitionModel, new PropertyModel<>(surveySectionDefinitionModel,
        "itemDefinitions")));
  }
}
