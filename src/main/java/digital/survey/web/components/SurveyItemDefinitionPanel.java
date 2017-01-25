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
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.template.components.ExtensibleFormDialog;
import guru.mmp.application.web.template.components.ExtensibleFormDialogImplementation;
import guru.mmp.application.web.template.components.TextFieldWithFeedback;
import guru.mmp.application.web.template.pages.TemplateDialogWebPage;
import org.apache.wicket.Component;
import org.apache.wicket.MarkupContainer;
import org.apache.wicket.ajax.AjaxRequestHandler;
import org.apache.wicket.ajax.AjaxRequestTarget;
import org.apache.wicket.ajax.markup.html.AjaxLink;
import org.apache.wicket.behavior.AttributeAppender;
import org.apache.wicket.markup.MarkupStream;
import org.apache.wicket.markup.head.IHeaderResponse;
import org.apache.wicket.markup.head.JavaScriptHeaderItem;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.form.TextField;
import org.apache.wicket.markup.html.panel.Panel;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.request.IRequestHandler;
import org.apache.wicket.request.Response;

import java.util.List;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyItemDefinitionPanel</code> class provides the base class that all input
 * panels for the different types of survey item definitions should be derived from.
 *
 * @author Marcus Portmann
 */
public abstract class SurveyItemDefinitionPanel extends Panel
{
  private static final long serialVersionUID = 1000000;

  /**
   * The web markup container that contains the body for the survey item definition.
   */
  private WebMarkupContainer bodyContainer;

  /**
   * The web markup container that contains the heading for the survey item definition.
   */
  private WebMarkupContainer headingContainer;

  /**
   * Constructs a new <code>SurveyItemDefinitionPanel</code>.
   *
   * @param id                         the non-null id of this component
   * @param surveyItemDefinitionsModel the model for the list of survey item definitions the
   *                                   survey item definition is associated with
   * @param surveyItemDefinitionModel  the model for the survey item definition
   */
  SurveyItemDefinitionPanel(String id,
      IModel<List<SurveyItemDefinition>> surveyItemDefinitionsModel,
      IModel<? extends SurveyItemDefinition> surveyItemDefinitionModel)
  {
    super(id);

    SurveyItemDefinition surveyItemDefinition = surveyItemDefinitionModel.getObject();

    // The "headingContainer" web markup container
    headingContainer = new WebMarkupContainer("headingContainer");
    headingContainer.setOutputMarkupId(true);
    add(headingContainer);

    // The custom "headingCollapse" component
    headingContainer.add(new Icon("icon"));

    headingContainer.add(new Label("name", new PropertyModel<String>(surveyItemDefinitionModel,
        "name")));

    headingContainer.add(new Label("label", new PropertyModel<String>(surveyItemDefinitionModel,
        "label")));

    // The "editLink" link
    AjaxLink<Void> editLink = new AjaxLink<Void>("editLink")
    {
      private static final long serialVersionUID = 1000000;

      @Override
      public void onClick(AjaxRequestTarget target)
      {
        getDialog().show(target, new EditItemDefinitionDialogImplementation(
            surveyItemDefinitionModel));

      }
    };
    headingContainer.add(editLink);

    // The "helpLink" link
    AjaxLink<Void> helpLink = new AjaxLink<Void>("helpLink")
    {
      private static final long serialVersionUID = 1000000;

      @Override
      public void onClick(AjaxRequestTarget target) {}
    };
    headingContainer.add(helpLink);

    // The "moveUpLink" link
    AjaxLink<Void> moveUpLink = new AjaxLink<Void>("moveUpLink")
    {
      private static final long serialVersionUID = 1000000;

      @Override
      public void onClick(AjaxRequestTarget target)
      {
        SurveyItemDefinition.moveItemDefinitionUp(surveyItemDefinitionsModel.getObject(),
            surveyItemDefinition);

        target.add(getParentSurveyItemDefinitionPanelGroup());
      }

      @Override
      public boolean isVisible()
      {
        return !SurveyItemDefinition.isFirstItemDefinition(surveyItemDefinitionsModel.getObject(),
            surveyItemDefinition);
      }
    };

    headingContainer.add(moveUpLink);

    // The "moveDownLink" link
    AjaxLink<Void> moveDownLink = new AjaxLink<Void>("moveDownLink")
    {
      private static final long serialVersionUID = 1000000;

      @Override
      public void onClick(AjaxRequestTarget target)
      {
        SurveyItemDefinition.moveItemDefinitionDown(surveyItemDefinitionsModel.getObject(),
            surveyItemDefinition);

        target.add(getParentSurveyItemDefinitionPanelGroup());
      }

      @Override
      public boolean isVisible()
      {
        return !SurveyItemDefinition.isLastItemDefinition(surveyItemDefinitionsModel.getObject(),
            surveyItemDefinition);
      }
    };

    headingContainer.add(moveDownLink);

    // The "removeLink" link
    AjaxLink<Void> removeLink = new AjaxLink<Void>("removeLink")
    {
      private static final long serialVersionUID = 1000000;

      @Override
      public void onClick(AjaxRequestTarget target)
      {
        getDialog().show(target, new RemoveItemDefinitionDialogImplementation(
            surveyItemDefinitionsModel, surveyItemDefinitionModel));

      }
    };
    headingContainer.add(removeLink);

    // The custom "headingCollapse" component
    headingContainer.add(new HeadingCollapse("headingCollapse"));

    // The "bodyContainer" web markup container
    bodyContainer = new WebMarkupContainer("bodyContainer");
    bodyContainer.setOutputMarkupId(true);

    if (isCollapsible())
    {
      bodyContainer.add(new AttributeAppender("class", "panel-collapse collapse", " "));
    }

    add(bodyContainer);
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

  /**
   * @param response the Wicket header response
   *
   * @see org.apache.wicket.markup.html.panel.Panel#renderHead(IHeaderResponse)
   */
  @Override
  public void renderHead(IHeaderResponse response)
  {
    super.renderHead(response);

    /*
     * Add the JavaScript, which alters the behaviour of the Bootstrap Tooltip to ensure that
     * tooltips are hidden when an element with a tooltip, associated with the survey item
     * definition panel, is clicked.
     */
    response.render(JavaScriptHeaderItem.forScript(generateTooltipJavaScript(getMarkupId(), false),
        null));
  }

  /**
   * Returns the web markup container that contains the body for the survey item definition.
   *
   * @return the web markup container that contains the body for the survey item definition
   */
  protected WebMarkupContainer getBodyContainer()
  {
    return bodyContainer;
  }

  /**
   * Return the web markup container that contains the heading for the survey item definition.
   *
   * @return the web markup container that contains the heading for the survey item definition
   */
  protected WebMarkupContainer getHeadingContainer()
  {
    return headingContainer;
  }

  /**
   * Returns the Font Awesome CSS class for the icon for the survey item definition.
   *
   * @return the Font Awesome CSS class for the icon for the survey item definition
   */
  protected abstract String getIconClass();

  /**
   * Return the parent survey item definition panel group for the survey item definition.
   *
   * @return the parent survey item definition panel group for the survey item definition or
   *         <code>null</code> if the parent survey item definition panel group cannot be found
   */
  protected SurveyItemDefinitionPanelGroup getParentSurveyItemDefinitionPanelGroup()
  {
    MarkupContainer parent = getParent();

    while (parent != null)
    {
      if (parent instanceof SurveyItemDefinitionPanelGroup)
      {
        return (SurveyItemDefinitionPanelGroup) parent;
      }

      parent = parent.getParent();
    }

    return null;
  }

  /**
   * Returns whether the survey item definition is collapsible.
   *
   * @return <code>true</code> if the survey item definition is collapsible or <code>false</code>
   *         otherwise
   */
  protected abstract boolean isCollapsible();

  /**
   * @see org.apache.wicket.markup.html.panel.Panel#onRender()
   */
  @Override
  protected void onRender()
  {
    super.onRender();

    /*
     * Add the JavaScript, which alters the behaviour of the Bootstrap Tooltip to ensure that
     * tooltips are hidden when an element with a tooltip, associated with the survey item
     * definition panel, is clicked.
     */
    IRequestHandler requestHandler = getRequestCycle().getActiveRequestHandler();

    if (requestHandler instanceof AjaxRequestHandler)
    {
      AjaxRequestHandler ajaxRequestHandler = (AjaxRequestHandler) requestHandler;

      ajaxRequestHandler.appendJavaScript(generateTooltipJavaScript(getMarkupId(), false));
    }
  }

  private String generateTooltipJavaScript(String id, boolean isAjaxRequest)
  {
    if (isAjaxRequest)
    {
      return String.format(
          "$('#%1$s').find('[data-toggle=\"tooltip\"]').on('click', function () { $(this).tooltip('hide'); });",
          id);
    }
    else
    {
      return String.format(
          "$(function() {$('#%1$s').find('[data-toggle=\"tooltip\"]').on('click', function () { $(this).tooltip('hide'); });});",
          id);
    }
  }

  /**
   * The <code>EditItemDefinitionDialogImplementation</code> class.
   *
   * @author Marcus Portmann
   */
  public class EditItemDefinitionDialogImplementation extends ExtensibleFormDialogImplementation
  {
    private IModel<? extends SurveyItemDefinition> surveyItemDefinitionModel;
    private String name;
    private String label;
    private String description;

    /**
     * Constructs a new <code>EditItemDefinitionDialogImplementation</code>.
     *
     *
     * @param surveyItemDefinitionModel the model for the survey item definition
     */
    public EditItemDefinitionDialogImplementation(
        IModel<? extends SurveyItemDefinition> surveyItemDefinitionModel)
    {
      super("Edit Survey Item Definition", "OK", "Cancel");

      this.surveyItemDefinitionModel = surveyItemDefinitionModel;

      SurveyItemDefinition surveyItemDefinition = surveyItemDefinitionModel.getObject();

      name = surveyItemDefinition.getName();
      label = surveyItemDefinition.getLabel();
      description = surveyItemDefinition.getDescription();

      // The "name" field
      TextField nameField = new TextFieldWithFeedback<>("name", new PropertyModel<>(this, "name"));
      nameField.setRequired(true);
      add(nameField);

      // The "label" field
      TextField labelField = new TextFieldWithFeedback<>("label", new PropertyModel<>(this,
          "label"));
      labelField.setRequired(true);
      add(labelField);

      // The "description" field
      TextField descriptionField = new TextFieldWithFeedback<>("description", new PropertyModel<>(
          this, "description"));
      descriptionField.setRequired(true);
      add(descriptionField);
    }

    @Override
    public void onCancel(AjaxRequestTarget target, Form form) {}

    @Override
    public void onError(AjaxRequestTarget target, Form form) {}

    @Override
    public boolean onSubmit(AjaxRequestTarget target, Form form)
    {
      SurveyItemDefinition surveyItemDefinition =
          (SurveyItemDefinition) surveyItemDefinitionModel.getObject();

      surveyItemDefinition.setName(name);
      surveyItemDefinition.setLabel(label);
      surveyItemDefinition.setDescription(description);

      target.add(getHeadingContainer());

      return true;
    }

    @Override
    public void resetModel() {}
  }


  /**
   * The <code>HeadingCollapse</code> class.
   */
  private class HeadingCollapse extends Component
  {
    private static final long serialVersionUID = 1000000;

    /**
     * Constructs a new <code>HeadingCollapse</code>.
     *
     * @param id the non-null id of this component
     */
    public HeadingCollapse(String id)
    {
      super(id);
    }

    /**
     * Render the XML panel.
     */
    @Override
    protected void onRender()
    {
      MarkupStream markupStream = findMarkupStream();
      Response response = getResponse();

      StringBuilder buffer = new StringBuilder();

      if (isCollapsible())
      {
        buffer.append(
            "<div class=\"heading-collapse collapsed\" data-toggle=\"collapse\" data-parent=\"#");
        buffer.append(getItemDefinitionPanelGroupId());
        buffer.append("\" href=\"#");
        buffer.append(getBodyContainer().getMarkupId());
        buffer.append(
            "\"><i data-toggle=\"tooltip\" data-original-title=\"Expand\" class=\"fa fa-plus collapsed\"></i>");

        buffer.append(
            "<i data-toggle=\"tooltip\" data-original-title=\"Collapse\" class=\"fa fa-minus expanded\"></i></div>");
      }
      else
      {
        // buffer.append("<div class=\"heading-collapse\"><i class=\"fa fa-square-o\"></i></div>");
      }

      response.write(buffer.toString());

      markupStream.next();
    }

    private String getItemDefinitionPanelGroupId()
    {
      MarkupContainer parent = SurveyItemDefinitionPanel.this.getParent();

      while ((parent != null) && (!parent.getId().equals("itemDefinitionPanelGroup")))
      {
        parent = parent.getParent();
      }

      if (parent != null)
      {
        return parent.getMarkupId();
      }
      else
      {
        throw new WebApplicationException("Failed to find the itemDefinitionPanelGroup component");
      }
    }
  }


  /**
   * The <code>Icon</code> class.
   */
  private class Icon extends Component
  {
    private static final long serialVersionUID = 1000000;

    /**
     * Constructs a new <code>Icon</code>.
     *
     * @param id the non-null id of this component
     */
    public Icon(String id)
    {
      super(id);
    }

    /**
     * Render the XML panel.
     */
    @Override
    protected void onRender()
    {
      MarkupStream markupStream = findMarkupStream();
      Response response = getResponse();

      response.write("<i class=\"fa " + getIconClass() + "\"></i>");

      markupStream.next();
    }
  }


  /**
   * The <code>RemoveItemDefinitionDialogImplementation</code> class.
   *
   * @author Marcus Portmann
   */
  public class RemoveItemDefinitionDialogImplementation extends ExtensibleFormDialogImplementation
  {
    private IModel<List<SurveyItemDefinition>> surveyItemDefinitionsModel;
    private IModel<? extends SurveyItemDefinition> surveyItemDefinitionModel;

    /**
     * Constructs a new <code>RemoveItemDefinitionDialogImplementation</code>.
     *
     * @param surveyItemDefinitionsModel the model for the list of survey item definitions the
     *                                   survey item definition is associated with
     * @param surveyItemDefinitionModel  the model for the survey item definition
     */
    public RemoveItemDefinitionDialogImplementation(
        IModel<List<SurveyItemDefinition>> surveyItemDefinitionsModel,
        IModel<? extends SurveyItemDefinition> surveyItemDefinitionModel)
    {
      super("Remove Survey Item Definition", "Yes", "No");

      this.surveyItemDefinitionsModel = surveyItemDefinitionsModel;
      this.surveyItemDefinitionModel = surveyItemDefinitionModel;

      /*
       * NOTE: We need to retrieve the label of the survey item definition here explicitly and not
       *       use a PropertyModel on the surveyItemDefinitionModel object with the "label" field
       *       because after removing the survey item definition the model will no longer be
       *       valid and we will get an IndexOutOfBoundsException exception. This is as a result of
       *       the surveyItemDefinitionModel being a ListItemModel, which references an item in
       *       a list view that has been removed.
       */
      add(new Label("label", new Model<>(surveyItemDefinitionModel.getObject().getLabel())));
    }

    @Override
    public void onCancel(AjaxRequestTarget target, Form form) {}

    @Override
    public void onError(AjaxRequestTarget target, Form form) {}

    @Override
    public boolean onSubmit(AjaxRequestTarget target, Form form)
    {
      SurveyItemDefinition.removeItemDefinition(surveyItemDefinitionsModel.getObject(),
          surveyItemDefinitionModel.getObject());

      target.add(getParentSurveyItemDefinitionPanelGroup());

      return true;
    }

    @Override
    public void resetModel() {}
  }
}
