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

package guru.mmp.survey.web.pages;

//~--- non-JDK imports --------------------------------------------------------

import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.WebSession;
import guru.mmp.application.web.pages.WebPageSecurity;
import guru.mmp.application.web.template.components.Dialog;
import guru.mmp.application.web.template.components.PagingNavigator;
import guru.mmp.application.web.template.pages.TemplateWebPage;
import guru.mmp.survey.model.ISurveyService;
import guru.mmp.survey.model.SurveyDefinition;
import guru.mmp.survey.web.SurveySecurity;
import guru.mmp.survey.web.data.FilteredLatestSurveyDefinitionDataProvider;
import org.apache.wicket.ajax.AjaxRequestTarget;
import org.apache.wicket.ajax.markup.html.AjaxLink;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.form.Button;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.form.TextField;
import org.apache.wicket.markup.html.link.Link;
import org.apache.wicket.markup.repeater.Item;
import org.apache.wicket.markup.repeater.ReuseIfModelsEqualStrategy;
import org.apache.wicket.markup.repeater.data.DataView;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.inject.Inject;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyDefinitionAdministrationPage</code> class implements the
 * "Survey Definition Administration" page for the web application.
 *
 * @author Marcus Portmann
 */
@WebPageSecurity(SurveySecurity.FUNCTION_CODE_SURVEY_ADMINISTRATION)
public class SurveyDefinitionAdministrationPage extends TemplateWebPage
{
  /* Logger */
  private static final Logger logger = LoggerFactory.getLogger(
    SurveyDefinitionAdministrationPage.class);
  private static final long serialVersionUID = 1000000;

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * Constructs a new <code>SurveyDefinitionAdministrationPage</code>.
   */
  public SurveyDefinitionAdministrationPage()
  {
    super("Surveys");

    try
    {
      WebSession session = getWebApplicationSession();

      UUID organisationId = session.getOrganisation().getId();

      /*
       * The table container, which allows the table and its associated navigator to be updated
       * using AJAX.
       */
      WebMarkupContainer tableContainer = new WebMarkupContainer("tableContainer");
      tableContainer.setOutputMarkupId(true);
      add(tableContainer);

      // The dialog used to confirm the removal of a survey definition
      RemoveDialog removeDialog = new RemoveDialog(tableContainer);
      add(removeDialog);

      // The "addLink" used to add a new survey definition
      Link<Void> addLink = new Link<Void>("addLink")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        public void onClick()
        {
          // setResponsePage(new AddSurveyDefinitionPage(getPageReference(), organisationId));
        }
      };
      tableContainer.add(addLink);

      FilteredLatestSurveyDefinitionDataProvider dataProvider = new FilteredLatestSurveyDefinitionDataProvider(
        organisationId);

      // The "filterForm" form
      Form<Void> filterForm = new Form<>("filterForm");
      filterForm.setMarkupId("filterForm");
      filterForm.setOutputMarkupId(true);

      // The "filter" field
      TextField<String> filterField = new TextField<>("filter", new PropertyModel<>(dataProvider,
        "filter"));
      filterForm.add(filterField);

      // The "filterButton" button
      Button filterButton = new Button("filterButton")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        public void onSubmit() {}
      };
      filterButton.setDefaultFormProcessing(true);
      filterForm.add(filterButton);

      // The "resetButton" button
      Button resetButton = new Button("resetButton")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        public void onSubmit()
        {
          dataProvider.setFilter("");
        }
      };
      filterForm.add(resetButton);

      tableContainer.add(filterForm);

      // The survey definition data view
      DataView<SurveyDefinition> dataView = new DataView<SurveyDefinition>("surveyDefinition",
        dataProvider)
      {
        private static final long serialVersionUID = 1000000;

        @Override
        protected void populateItem(Item<SurveyDefinition> item)
        {
          item.add(new Label("name", new PropertyModel<String>(item.getModel(), "name")));
          item.add(new Label("version", new PropertyModel<String>(item.getModel(), "version")));

          // The "instancesLink" link
          Link<Void> membersLink = new Link<Void>("surveyInstancesLink")
          {
            private static final long serialVersionUID = 1000000;

            @Override
            public void onClick()
            {
              SurveyDefinition surveyDefinition = item.getModelObject();

              UUID surveyDefinitionId = surveyDefinition.getId();
              String surveyDefinitionName = surveyDefinition.getName();

//              setResponsePage(new SurveyInstanceAdministrationPage(getPageReference(),
//                surveyDefinitionId, surveyDefinitionName));
            }
          };
          item.add(membersLink);

          // The "updateLink" link
          Link<Void> updateLink = new Link<Void>("updateLink")
          {
            private static final long serialVersionUID = 1000000;

            @Override
            public void onClick()
            {
//            UpdateSurveyDefinitionPage page = new UpdateSurveyDefinitionPage(
//              getPageReference(), item.getModel());
//
//            setResponsePage(page);
            }
          };
          item.add(updateLink);

          // The "removeLink" link
          AjaxLink<Void> removeLink = new AjaxLink<Void>("removeLink")
          {
            private static final long serialVersionUID = 1000000;

            @Override
            public void onClick(AjaxRequestTarget target)
            {
              SurveyDefinition surveyAudience = item.getModelObject();

              if (surveyAudience != null)
              {
                removeDialog.show(target, surveyAudience);
              }
              else
              {
                target.add(tableContainer);
              }
            }
          };
          item.add(removeLink);
        }
      };
      dataView.setItemsPerPage(10);
      dataView.setItemReuseStrategy(ReuseIfModelsEqualStrategy.getInstance());
      tableContainer.add(dataView);

      tableContainer.add(new PagingNavigator("navigator", dataView));
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(
        "Failed to initialise the SurveyDefinitionAdministrationPage", e);
    }
  }

  /**
   * The <code>RemoveDialog</code> class implements a dialog that allows the removal of a
   * survey definition to be confirmed.
   */
  private class RemoveDialog extends Dialog
  {
    private static final long serialVersionUID = 1000000;
    private UUID id;
    private Label nameLabel;

    /**
     * Constructs a new <code>RemoveDialog</code>.
     *
     * @param tableContainer the table container, which allows the survey definition table and its
     *                       associated navigator to be updated using AJAX
     */
    public RemoveDialog(WebMarkupContainer tableContainer)
    {
      super("removeDialog");

      nameLabel = new Label("name", Model.of(""));

      nameLabel.setOutputMarkupId(true);
      add(nameLabel);

      // The "removeLink" link
      AjaxLink<Void> removeLink = new AjaxLink<Void>("removeLink")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        public void onClick(AjaxRequestTarget target)
        {
          try
          {
            // surveyService.deleteSurveyDefinition(id)

            target.add(tableContainer);

            SurveyDefinitionAdministrationPage.this.info("Successfully removed the audience "
              + nameLabel.getDefaultModelObjectAsString());
          }
          catch (Throwable e)
          {
            logger.error(String.format("Failed to remove the audience (%s): %s", id,
              e.getMessage()), e);

            SurveyDefinitionAdministrationPage.this.error("Failed to remove the audience "
              + nameLabel.getDefaultModelObjectAsString());
          }

          target.add(getAlerts());

          hide(target);
        }
      };
      add(removeLink);
    }

    /**
     * Show the dialog using Ajax.
     *
     * @param target           the AJAX request target
     * @param surveyDefinition the survey definition being removed
     */
    public void show(AjaxRequestTarget target, SurveyDefinition surveyDefinition)
    {
      id = surveyDefinition.getId();

      nameLabel.setDefaultModelObject(surveyDefinition.getName());

      target.add(nameLabel);

      super.show(target);
    }
  }
}
