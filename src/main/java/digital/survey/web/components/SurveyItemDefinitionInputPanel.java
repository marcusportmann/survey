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
import digital.survey.model.SurveyItemDefinition;
import guru.mmp.application.web.template.components.ExtensibleFormDialog;
import guru.mmp.application.web.template.components.InputPanel;
import guru.mmp.application.web.template.pages.TemplateDialogWebPage;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.link.Link;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.PropertyModel;

/**
 * The <code>SurveyItemDefinitionInputPanel</code> class provides the base class that all input
 * panels for the different types of survey item definitions should be derived from.
 *
 * @author Marcus Portmann
 */
public abstract class SurveyItemDefinitionInputPanel extends InputPanel
{
  private static final long serialVersionUID = 1000000;
  private WebMarkupContainer itemDefinitionHeader;

  /**
   * Constructs a new <code>SurveyItemDefinitionInputPanel</code>.
   *
   * @param id                        the non-null id of this component
   * @param surveyDefinitionModel     the model for the survey definition
   * @param surveyItemDefinitionModel the model for the survey item definition
   */
  SurveyItemDefinitionInputPanel(String id, IModel<SurveyDefinition> surveyDefinitionModel,
      IModel<? extends SurveyItemDefinition> surveyItemDefinitionModel)
  {
    super(id);

    setOutputMarkupId(true);

    SurveyDefinition surveyDefinition = surveyDefinitionModel.getObject();

    SurveyItemDefinition surveyItemDefinition = surveyItemDefinitionModel.getObject();

    itemDefinitionHeader = new WebMarkupContainer("itemDefinitionHeader");
    itemDefinitionHeader.setOutputMarkupId(true);
    add(itemDefinitionHeader);

    itemDefinitionHeader.add(new Label("name", new PropertyModel<String>(surveyItemDefinitionModel,
        "name")));

    itemDefinitionHeader.add(new Label("label", new PropertyModel<String>(
        surveyItemDefinitionModel, "label")));

    // The "editLink" link
    Link<Void> editLink = new Link<Void>("editLink")
    {
      private static final long serialVersionUID = 1000000;

      @Override
      public void onClick() {}
    };
    itemDefinitionHeader.add(editLink);

    // The "helpLink" link
    Link<Void> helpLink = new Link<Void>("helpLink")
    {
      private static final long serialVersionUID = 1000000;

      @Override
      public void onClick() {}
    };
    itemDefinitionHeader.add(helpLink);

    // The "copyLink" link
    Link<Void> copyLink = new Link<Void>("copyLink")
    {
      private static final long serialVersionUID = 1000000;

      @Override
      public void onClick() {}
    };
    itemDefinitionHeader.add(copyLink);

    // The "moveUpLink" link
    Link<Void> moveUpLink = new Link<Void>("moveUpLink")
    {
      private static final long serialVersionUID = 1000000;

      @Override
      public void onClick() {}
    };

    moveUpLink.setVisible(!surveyDefinition.isFirstItemDefinition(surveyItemDefinition));

    itemDefinitionHeader.add(moveUpLink);

    // The "moveDownLink" link
    Link<Void> moveDownLink = new Link<Void>("moveDownLink")
    {
      private static final long serialVersionUID = 1000000;

      @Override
      public void onClick() {}
    };

    moveDownLink.setVisible(!surveyDefinition.isLastItemDefinition(surveyItemDefinition));

    itemDefinitionHeader.add(moveDownLink);

    // The "removeLink" link
    Link<Void> removeLink = new Link<Void>("removeLink")
    {
      private static final long serialVersionUID = 1000000;

      @Override
      public void onClick() {}
    };
    itemDefinitionHeader.add(removeLink);
  }

  /**
   * Returns the extensible form dialog associated with the page.
   *
   * @return the extensible form dialog associated with the page
   */
  public ExtensibleFormDialog getDialog()
  {
    return ((TemplateDialogWebPage) getPage()).getDialog();
  }
}
