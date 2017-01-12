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
import digital.survey.model.SurveyResponse;
import guru.mmp.application.web.template.components.InputPanel;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.PropertyModel;

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

    IModel<SurveyDefinition> surveyDefinitionModel = new PropertyModel<>(surveyResponseModel,
        "instance.definition");

    add(new SurveyItemResponsePanelGroup("itemResponsePanelGroup", surveyDefinitionModel,
        new PropertyModel<>(surveyDefinitionModel, "itemDefinitions"), surveyResponseModel));
  }
}
