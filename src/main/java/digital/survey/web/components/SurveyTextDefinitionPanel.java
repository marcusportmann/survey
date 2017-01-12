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
import digital.survey.model.SurveyTextDefinition;
import org.apache.wicket.model.IModel;

/**
 * The <code>SurveyTextDefinitionPanel</code> class.
 *
 * @author Marcus Portmann
 */
public class SurveyTextDefinitionPanel extends SurveyItemDefinitionPanel
{
  private static final long serialVersionUID = 1000000;

  /**
   * Constructs a new <code>SurveyTextDefinitionPanel</code>.
   *
   * @param id                        the non-null id of this component
   * @param surveyDefinitionModel     the model for the survey definition
   * @param surveyTextDefinitionModel the model for the survey text definition
   */
  public SurveyTextDefinitionPanel(String id, IModel<SurveyDefinition> surveyDefinitionModel,
      IModel<SurveyTextDefinition> surveyTextDefinitionModel)
  {
    super(id, surveyDefinitionModel, surveyTextDefinitionModel);
  }

  /**
   * Returns the Font Awesome CSS class for the icon for the survey item definition.
   *
   * @return the Font Awesome CSS class for the icon for the survey item definition
   */
  @Override
  protected String getIconClass()
  {
    return "fa-font";
  }

  /**
   * Returns whether the survey item definition is collapsible.
   *
   * @return <code>true</code> if the survey item definition is collapsible or <code>false</code>
   *         otherwise
   */
  @Override
  protected boolean isCollapsible()
  {
    return false;
  }
}
