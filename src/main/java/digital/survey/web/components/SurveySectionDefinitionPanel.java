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

import digital.survey.model.SurveyItemDefinition;
import digital.survey.model.SurveySectionDefinition;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.PropertyModel;

import java.util.List;

//~--- JDK imports ------------------------------------------------------------

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
   * @param surveyItemDefinitionsModel   the model for the list of survey item definitions the
   *                                     survey section definition is associated with
   * @param surveySectionDefinitionModel the model for the survey section definition
   */
  public SurveySectionDefinitionPanel(String id,
      IModel<List<SurveyItemDefinition>> surveyItemDefinitionsModel,
      IModel<SurveySectionDefinition> surveySectionDefinitionModel)
  {
    super(id, surveyItemDefinitionsModel, surveySectionDefinitionModel);

    getBodyContainer().add(new SurveyItemDefinitionPanelGroup("itemDefinitionPanelGroup",
        new PropertyModel<>(surveySectionDefinitionModel, "itemDefinitions")));
  }

  /**
   * Returns the Font Awesome CSS class for the icon for the survey item definition.
   *
   * @return the Font Awesome CSS class for the icon for the survey item definition
   */
  @Override
  protected String getIconClass()
  {
    return "fa-bars";
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
    return true;
  }
}
