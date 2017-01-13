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
import digital.survey.model.SurveyResult;
import guru.mmp.application.web.template.components.InputPanel;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.PropertyModel;

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

    IModel<SurveyDefinition> surveyDefinitionModel = new PropertyModel<>(surveyResultModel,
      "instance.definition");

    add(new SurveyItemResultPanelGroup("itemResultPanelGroup", surveyDefinitionModel,
      new PropertyModel<>(surveyDefinitionModel, "itemDefinitions"), surveyResultModel));
  }
}
