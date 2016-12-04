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

import digital.survey.model.SurveyDefinition;
import guru.mmp.application.web.template.components.InputPanel;
import org.apache.wicket.model.IModel;

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
   * @param id                    the non-null id of this component
   * @param surveyGroupRatingsDefinitionModel the model for the survey response
   */
  public SurveyGroupRatingsDefinitionInputPanel(String id, IModel<SurveyDefinition> surveyDefinitionModel)
  {
    super(id, surveyDefinitionModel);
  }
}
