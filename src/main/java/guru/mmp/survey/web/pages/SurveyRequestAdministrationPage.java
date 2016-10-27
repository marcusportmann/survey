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
import guru.mmp.common.util.DateUtil;
import guru.mmp.survey.model.ISurveyService;
import guru.mmp.survey.model.SurveyRequest;
import guru.mmp.survey.web.SurveySecurity;
import guru.mmp.survey.web.data.FilteredSurveyRequestDataProvider;
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
 * The <code>SurveyRequestAdministrationPage</code> class implements the
 * "Survey Request Administration" page for the web application.
 *
 * @author Marcus Portmann
 */
@SuppressWarnings("CdiManagedBeanInconsistencyInspection")
@WebPageSecurity({ SurveySecurity.FUNCTION_CODE_SURVEY_ADMINISTRATION,
  SurveySecurity.FUNCTION_CODE_VIEW_SURVEY_RESPONSE })
public class SurveyRequestAdministrationPage extends TemplateWebPage
{
  /* Logger */
  private static final Logger logger = LoggerFactory.getLogger(
    SurveyRequestAdministrationPage.class);
  private static final long serialVersionUID = 1000000;

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * Constructs a new <code>SurveyRequestAdministrationPage</code>.
   *
   * @param previousPage       the previous page
   * @param surveyInstanceId   the Universally Unique Identifier (UUID) used to identify the survey
   *                           instance the survey requests are associated with
   * @param surveyInstanceName the name of the survey request
   */
  public SurveyRequestAdministrationPage(PageReference previousPage, UUID surveyInstanceId,
    String surveyInstanceName)
  {
    super("Survey Requests", surveyInstanceName);

    try
    {
      WebSession session = getWebApplicationSession();

      /*
       * The table container, which allows the table and its associated navigator to be updated
       * using AJAX.
       */
      WebMarkupContainer tableContainer = new WebMarkupContainer("tableContainer");
      tableContainer.setOutputMarkupId(true);
      add(tableContainer);

      // The dialog used to confirm the removal of a survey request
      RemoveDialog removeDialog = new RemoveDialog(tableContainer);
      add(removeDialog);

      // The "addLink" used to add a new survey request
      Link<Void> addLink = new Link<Void>("addLink")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        public void onClick()
        {
          // setResponsePage(new AddSurveyRequestPage(getPageReference(), surveyInstanceId));
        }
      };
      tableContainer.add(addLink);

      FilteredSurveyRequestDataProvider dataProvider =
        new FilteredSurveyRequestDataProvider(surveyInstanceId);

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

      // The survey request data view
      DataView<SurveyRequest> dataView = new DataView<SurveyRequest>(
        "surveyRequest", dataProvider)
      {
        private static final long serialVersionUID = 1000000;

        @Override
        protected void populateItem(Item<SurveyRequest> item)
        {
          SurveyRequest surveyRequest = item.getModelObject();

          item.add(new Label("name", new PropertyModel<String>(item.getModel(), "fullName")));
          item.add(new Label("email", new PropertyModel<String>(item.getModel(), "email")));
          item.add(new Label("sent", new PropertyModel<String>(item.getModel(), "sentAsString")));

          // The "updateLink" link
          Link<Void> updateLink = new Link<Void>("updateLink")
          {
            private static final long serialVersionUID = 1000000;

            @Override
            public void onClick()
            {
//            UpdateSurveyRequestPage page = new UpdateSurveyRequestPage(
//              getPageReference(), item.getModel());
//
//            setResponsePage(page);
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
              SurveyRequest surveyInstance = item.getModelObject();

              if (surveyInstance != null)
              {
                removeDialog.show(target, surveyInstance);
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
        "Failed to initialise the SurveyRequestAdministrationPage", e);
    }
  }

  /**
   * The <code>RemoveDialog</code> class implements a dialog that allows the removal of a
   * survey request to be confirmed.
   */
  private class RemoveDialog extends Dialog
  {
    private static final long serialVersionUID = 1000000;
    private UUID id;
    private Label nameLabel;

    /**
     * Constructs a new <code>RemoveDialog</code>.
     *
     * @param tableContainer the table container, which allows the survey request table and its
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
            // surveyService.deleteSurveyRequest(id)

            target.add(tableContainer);

            SurveyRequestAdministrationPage.this.info(
              "Successfully removed the survey request "
                + nameLabel.getDefaultModelObjectAsString());
          }
          catch (Throwable e)
          {
            logger.error(String.format("Failed to remove the survey request (%s): %s", id,
              e.getMessage()), e);

            SurveyRequestAdministrationPage.this.error(
              "Failed to remove the survey request "
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
     * @param target         the AJAX request target
     * @param surveyRequest the survey request being removed
     */
    public void show(AjaxRequestTarget target, SurveyRequest surveyRequest)
    {
      id = surveyRequest.getId();

      nameLabel.setDefaultModelObject(surveyRequest.getFullName());

      target.add(nameLabel);

      super.show(target);
    }
  }
}
