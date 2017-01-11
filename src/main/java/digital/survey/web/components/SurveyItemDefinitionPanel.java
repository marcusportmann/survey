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
import guru.mmp.application.web.template.pages.TemplateDialogWebPage;
import org.apache.wicket.Component;
import org.apache.wicket.MarkupContainer;
import org.apache.wicket.markup.MarkupElement;
import org.apache.wicket.markup.MarkupStream;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.link.Link;
import org.apache.wicket.markup.html.panel.Panel;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.request.Response;

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
   * @param id                        the non-null id of this component
   * @param surveyDefinitionModel     the model for the survey definition
   * @param surveyItemDefinitionModel the model for the survey item definition
   * @param iconClass                 the Fontawesome CSS class for the icon for the survey item
   *                                  definition
   * @param hasBodyContent            <code>true</code> if the the survey item definition has body
   *                                  content that can be expanded and collapsed or
   *                                  <code>false</code> otherwise
   */
  SurveyItemDefinitionPanel(String id, IModel<SurveyDefinition> surveyDefinitionModel,
      IModel<? extends SurveyItemDefinition> surveyItemDefinitionModel, String iconClass,
      boolean hasBodyContent)
  {
    super(id);

    SurveyDefinition surveyDefinition = surveyDefinitionModel.getObject();

    SurveyItemDefinition surveyItemDefinition = surveyItemDefinitionModel.getObject();

    // The "headingContainer" web markup container
    headingContainer = new WebMarkupContainer("headingContainer");
    headingContainer.setOutputMarkupId(true);
    add(headingContainer);

    // The custom "headingCollapse" component
    headingContainer.add(new Icon("icon", iconClass));

    headingContainer.add(new Label("name", new PropertyModel<String>(surveyItemDefinitionModel,
        "name")));

    headingContainer.add(new Label("label", new PropertyModel<String>(surveyItemDefinitionModel,
        "label")));

    // The "editLink" link
    Link<Void> editLink = new Link<Void>("editLink")
    {
      private static final long serialVersionUID = 1000000;

      @Override
      public void onClick() {}
    };
    headingContainer.add(editLink);

    // The "helpLink" link
    Link<Void> helpLink = new Link<Void>("helpLink")
    {
      private static final long serialVersionUID = 1000000;

      @Override
      public void onClick() {}
    };
    headingContainer.add(helpLink);

    // The "copyLink" link
    Link<Void> copyLink = new Link<Void>("copyLink")
    {
      private static final long serialVersionUID = 1000000;

      @Override
      public void onClick() {}
    };
    headingContainer.add(copyLink);

    // The "moveUpLink" link
    Link<Void> moveUpLink = new Link<Void>("moveUpLink")
    {
      private static final long serialVersionUID = 1000000;

      @Override
      public void onClick() {}
    };

    moveUpLink.setVisible(!surveyDefinition.isFirstItemDefinition(surveyItemDefinition));

    headingContainer.add(moveUpLink);

    // The "moveDownLink" link
    Link<Void> moveDownLink = new Link<Void>("moveDownLink")
    {
      private static final long serialVersionUID = 1000000;

      @Override
      public void onClick() {}
    };

    moveDownLink.setVisible(!surveyDefinition.isLastItemDefinition(surveyItemDefinition));

    headingContainer.add(moveDownLink);

    // The "removeLink" link
    Link<Void> removeLink = new Link<Void>("removeLink")
    {
      private static final long serialVersionUID = 1000000;

      @Override
      public void onClick() {}
    };
    headingContainer.add(removeLink);

    // The custom "headingCollapse" component
    headingContainer.add(new HeadingCollapse("headingCollapse", hasBodyContent));

    // The "bodyContainer" web markup container
    bodyContainer = new WebMarkupContainer("bodyContainer");
    bodyContainer.setOutputMarkupId(true);
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
   * The <code>Icon</code> class.
   */
  private class Icon extends Component
  {
    private static final long serialVersionUID = 1000000;

    private String iconClass;

    /**
     * Constructs a new <code>Icon</code>.
     *
     * @param id        the non-null id of this component
     * @param iconClass the Fontawesome CSS class for the icon
     */
    public Icon(String id, String iconClass)
    {
      super(id);

      this.iconClass = iconClass;
    }

    /**
     * Render the XML panel.
     */
    @Override
    protected void onRender()
    {
      MarkupStream markupStream = findMarkupStream();
      Response response = getResponse();

      response.write("<i class=\"fa " + iconClass + "\"></i>");

      markupStream.next();
    }
  }

  /**
   * The <code>HeadingCollapse</code> class.
   */
  private class HeadingCollapse extends Component
  {
    private static final long serialVersionUID = 1000000;

    private boolean isCollapsible;

    /**
     * Constructs a new <code>HeadingCollapse</code>.
     *
     * @param id the non-null id of this component
     * @param isCollapsible  <code>true</code> if the the survey item definition has body content
     *                       that can be expanded and collapsed or <code>false</code> otherwise
     */
    public HeadingCollapse(String id, boolean isCollapsible)
    {
      super(id);

      this.isCollapsible = isCollapsible;
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

      if (isCollapsible)
      {
        buffer.append("<div class=\"heading-collapse\" data-toggle=\"collapse\" data-parent=\"#");
        buffer.append(getItemDefinitionPanelGroupId());
        buffer.append("\" href=\"#");
        buffer.append(getBodyContainer().getMarkupId());
        buffer.append(
          "\"><i data-toggle=\"tooltip\" data-original-title=\"Expand\" class=\"fa fa-arrow-down collapsed\"></i>");

        buffer.append(
          "<i data-toggle=\"tooltip\" data-original-title=\"Collapse\" class=\"fa fa-arrow-up expanded\"></i></div>");
      }
      else
      {
        buffer.append("<div class=\"heading-collapse\"><i class=\"fa fa-square-o\"></i></div>");
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

      return parent.getMarkupId();
    }
  }
}
