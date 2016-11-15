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

package digital.survey.web.pages;

//~--- non-JDK imports --------------------------------------------------------

import digital.survey.model.ISurveyService;
import digital.survey.model.SurveyInstance;
import digital.survey.model.SurveyResponse;
import digital.survey.model.SurveyResponseSummary;
import digital.survey.web.SurveySecurity;
import digital.survey.web.data.FilteredSurveyResponseSummaryDataProvider;
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.WebSession;
import guru.mmp.application.web.pages.WebPageSecurity;
import guru.mmp.application.web.template.components.Dialog;
import guru.mmp.application.web.template.components.PagingNavigator;
import guru.mmp.application.web.template.pages.TemplateWebPage;
import org.apache.wicket.PageReference;
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
 * The <code>SurveyResponseAdministrationPage</code> class implements the
 * "Survey Response Administration" page for the web application.
 *
 * @author Marcus Portmann
 */
@SuppressWarnings("CdiManagedBeanInconsistencyInspection")
@WebPageSecurity({ SurveySecurity.FUNCTION_CODE_SURVEY_ADMINISTRATION,
    SurveySecurity.FUNCTION_CODE_VIEW_SURVEY_RESPONSE })
public class SurveyResponseAdministrationPage extends TemplateWebPage
{
  /* Logger */
  private static final Logger logger = LoggerFactory.getLogger(
      SurveyResponseAdministrationPage.class);
  private static final long serialVersionUID = 1000000;

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * Constructs a new <code>SurveyResponseAdministrationPage</code>.
   *
   * @param previousPage       the previous page
   * @param surveyInstanceId   the Universally Unique Identifier (UUID) used to identify the survey
   *                           instance the survey responses are associated with
   * @param surveyInstanceName the name of the survey instance
   */
  public SurveyResponseAdministrationPage(PageReference previousPage, UUID surveyInstanceId,
      String surveyInstanceName)
  {
    super("Survey Responses", surveyInstanceName);

    try
    {
      WebSession session = getWebApplicationSession();

      SurveyInstance surveyInstance = surveyService.getSurveyInstance(surveyInstanceId);

      /*
       * The table container, which allows the table and its associated navigator to be updated
       * using AJAX.
       */
      WebMarkupContainer tableContainer = new WebMarkupContainer("tableContainer");
      tableContainer.setOutputMarkupId(true);
      add(tableContainer);

      // The dialog used to confirm the removal of a survey response
      RemoveDialog removeDialog = new RemoveDialog(tableContainer);
      add(removeDialog);

      // The "addLink" used to add a new survey response for anonymous surveys only
      Link<Void> addLink = new Link<Void>("addLink")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        public void onClick()
        {
          setResponsePage(new AddSurveyResponsePage(getPageReference(), surveyInstanceId,
              surveyInstanceName));
        }
      };
      addLink.setVisible(surveyInstance.getDefinition().isAnonymous());
      tableContainer.add(addLink);

      FilteredSurveyResponseSummaryDataProvider dataProvider =
          new FilteredSurveyResponseSummaryDataProvider(surveyInstanceId);

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

      // The "backLink" link
      Link<Void> backLink = new Link<Void>("backLink")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        public void onClick()
        {
          setResponsePage(previousPage.getPage());
        }
      };
      tableContainer.add(backLink);

      // The survey response data view
      DataView<SurveyResponseSummary> dataView = new DataView<SurveyResponseSummary>(
          "surveyResponseSummary", dataProvider)
      {
        private static final long serialVersionUID = 1000000;

        @Override
        protected void populateItem(Item<SurveyResponseSummary> item)
        {
          item.add(new Label("name", new PropertyModel<String>(item.getModel(), "name")));
          item.add(new Label("responded", new PropertyModel<String>(item.getModel(),
              "respondedAsString")));

          // The "viewLink" link
          Link<Void> viewLink = new Link<Void>("viewLink")
          {
            private static final long serialVersionUID = 1000000;

            @Override
            public void onClick()
            {
              SurveyResponseSummary surveyResponseSummary = item.getModelObject();

              try
              {
                SurveyResponse surveyResponse = surveyService.getSurveyResponse(
                    surveyResponseSummary.getId());

                ViewSurveyResponsePage page = new ViewSurveyResponsePage(getPageReference(),
                    new Model<>(surveyResponse));

                setResponsePage(page);
              }
              catch (Throwable e)
              {
                logger.error("Failed to retrieve the survey response ("
                    + surveyResponseSummary.getId() + "): " + e.getMessage(), e);
                SurveyResponseAdministrationPage.this.error(
                    "Failed to retrieve the survey response (" + surveyResponseSummary.getName()
                    + ")");
              }
            }
          };
          item.add(viewLink);

          // The "updateLink" link
          Link<Void> updateLink = new Link<Void>("updateLink")
          {
            private static final long serialVersionUID = 1000000;

            @Override
            public void onClick()
            {
              SurveyResponseSummary surveyResponseSummary = item.getModelObject();

              try
              {
                SurveyResponse surveyResponse = surveyService.getSurveyResponse(
                    surveyResponseSummary.getId());

                UpdateSurveyResponsePage page = new UpdateSurveyResponsePage(getPageReference(),
                    new Model<>(surveyResponse));

                setResponsePage(page);
              }
              catch (Throwable e)
              {
                logger.error("Failed to retrieve the survey response ("
                    + surveyResponseSummary.getId() + "): " + e.getMessage(), e);
                SurveyResponseAdministrationPage.this.error(
                    "Failed to retrieve the survey response (" + surveyResponseSummary.getName()
                    + ")");

              }
            }
          };
          updateLink.setVisible(session.hasAcccessToFunction(SurveySecurity
              .FUNCTION_CODE_SURVEY_ADMINISTRATION));
          item.add(updateLink);

          // The "removeLink" link
          AjaxLink<Void> removeLink = new AjaxLink<Void>("removeLink")
          {
            private static final long serialVersionUID = 1000000;

            @Override
            public void onClick(AjaxRequestTarget target)
            {
              SurveyResponseSummary surveyResponseSummary = item.getModelObject();

              if (surveyResponseSummary != null)
              {
                removeDialog.show(target, surveyResponseSummary);
              }
              else
              {
                target.add(tableContainer);
              }
            }
          };
          removeLink.setVisible(session.hasAcccessToFunction(SurveySecurity
              .FUNCTION_CODE_SURVEY_ADMINISTRATION));
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
          "Failed to initialise the SurveyResponseAdministrationPage", e);
    }
  }

  /**
   * The <code>RemoveDialog</code> class implements a dialog that allows the removal of a
   * survey response to be confirmed.
   */
  private class RemoveDialog extends Dialog
  {
    private static final long serialVersionUID = 1000000;
    private UUID id;
    private Label nameLabel;

    /**
     * Constructs a new <code>RemoveDialog</code>.
     *
     * @param tableContainer the table container, which allows the survey response table and its
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
            surveyService.deleteSurveyResponse(id);

            target.add(tableContainer);

            SurveyResponseAdministrationPage.this.info(
                "Successfully removed the survey response for "
                + nameLabel.getDefaultModelObjectAsString());
          }
          catch (Throwable e)
          {
            logger.error(String.format("Failed to remove the survey response (%s): %s", id,
                e.getMessage()), e);

            SurveyResponseAdministrationPage.this.error("Failed to remove the survey response for "
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
     * @param target                the AJAX request target
     * @param surveyResponseSummary the survey response being removed
     */
    public void show(AjaxRequestTarget target, SurveyResponseSummary surveyResponseSummary)
    {
      id = surveyResponseSummary.getId();

      nameLabel.setDefaultModelObject(surveyResponseSummary.getName());

      target.add(nameLabel);

      super.show(target);
    }
  }
}
