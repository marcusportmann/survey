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

import org.apache.wicket.Component;
import org.apache.wicket.extensions.wizard.AjaxWizardButtonBar;
import org.apache.wicket.extensions.wizard.Wizard;
import org.apache.wicket.extensions.wizard.dynamic.DynamicWizardModel;
import org.apache.wicket.extensions.wizard.dynamic.DynamicWizardStep;
import org.apache.wicket.extensions.wizard.dynamic.IDynamicWizardStep;
import org.apache.wicket.model.ResourceModel;

/**
 * The <code>NewSurveyItemDefinitionWizard</code> class
 *
 * @author Marcus Portmann
 */
public class NewSurveyItemDefinitionWizard extends Wizard
{
  /**
   * Constructs a new <code>NewSurveyItemDefinitionWizard</code>.
   *
   * @param id the non-null id of this component
   */
  public NewSurveyItemDefinitionWizard(String id)
  {
    super(id);

    init(new DynamicWizardModel(new SelectTypeStep()));
  }

  @Override
  protected Component newButtonBar(String id)
  {
    return super.newButtonBar(id);
  }

  /**
   * The <code>ConfirmationStep</code> class.
   */
  private class ConfirmationStep extends DynamicWizardStep
  {
    /**
     * Constructs a new <code>ConfirmationStep</code>.
     */
    public ConfirmationStep()
    {
      super(null, new ResourceModel("confirmationStep.title"), null);
    }

    @Override
    public boolean isLastStep()
    {
      return true;
    }

    @Override
    public IDynamicWizardStep next()
    {
      return null;
    }
  }


  /**
   * The <code>SelectTypeStep</code> class.
   */
  private class SelectTypeStep extends DynamicWizardStep
  {
    /**
     * Constructs a new <code>SelectTypeStep</code>.
     */
    public SelectTypeStep()
    {
      super(null, new ResourceModel("selectTypeStep.title"), null);
    }

    @Override
    public boolean isLastStep()
    {
      return false;
    }

    @Override
    public IDynamicWizardStep next()
    {
      return new ConfirmationStep();
    }
  }
}
