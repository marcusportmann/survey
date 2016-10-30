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

import digital.survey.model.SurveyAudience;
import digital.survey.model.SurveyAudienceMember;
import digital.survey.web.SurveySecurity;
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.WebSession;
import guru.mmp.application.web.pages.WebPageSecurity;
import guru.mmp.application.web.template.components.Dialog;
import guru.mmp.application.web.template.components.PagingNavigator;
import guru.mmp.application.web.template.pages.TemplateWebPage;
import digital.survey.model.ISurveyService;
import digital.survey.web.data.FilteredSurveyAudienceMemberDataProvider;
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
 * The <code>SurveyAudienceMemberAdministrationPage</code> class implements the
 * "Survey Audience Member Administration" page for the web application.
 *
 * @author Marcus Portmann
 */
@SuppressWarnings("CdiManagedBeanInconsistencyInspection")
@WebPageSecurity(SurveySecurity.FUNCTION_CODE_SURVEY_AUDIENCE_ADMINISTRATION)
public class SurveyAudienceMemberAdministrationPage extends TemplateWebPage
{
  /* Logger */
  private static final Logger logger = LoggerFactory.getLogger(
      SurveyAudienceMemberAdministrationPage.class);
  private static final long serialVersionUID = 1000000;

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * Constructs a new <code>SurveyAudienceMemberAdministrationPage</code>.
   *
   * @param previousPage   the previous page
   * @param surveyAudience the survey audience the survey audience members are associated with
   */
  public SurveyAudienceMemberAdministrationPage(PageReference previousPage, SurveyAudience surveyAudience)
  {
    super("Audience Members", surveyAudience.getName());

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

      // The dialog used to confirm the removal of a survey audience member
      RemoveDialog removeDialog = new RemoveDialog(tableContainer);
      add(removeDialog);

      // The "addLink" used to add a new survey audience member
      Link<Void> addLink = new Link<Void>("addLink")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        public void onClick()
        {
          setResponsePage(new AddSurveyAudienceMemberPage(getPageReference(), surveyAudience));
        }
      };
      tableContainer.add(addLink);

      FilteredSurveyAudienceMemberDataProvider dataProvider =
          new FilteredSurveyAudienceMemberDataProvider(surveyAudience.getId());

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

      // The survey audience member data view
      DataView<SurveyAudienceMember> dataView = new DataView<SurveyAudienceMember>(
          "surveyAudienceMember", dataProvider)
      {
        private static final long serialVersionUID = 1000000;

        @Override
        protected void populateItem(Item<SurveyAudienceMember> item)
        {
          item.add(new Label("firstName", new PropertyModel<String>(item.getModel(), "firstName")));
          item.add(new Label("lastName", new PropertyModel<String>(item.getModel(), "lastName")));

          // The "updateLink" link
          Link<Void> updateLink = new Link<Void>("updateLink")
          {
            private static final long serialVersionUID = 1000000;

            @Override
            public void onClick()
            {
              UpdateSurveyAudienceMemberPage page = new UpdateSurveyAudienceMemberPage(
                getPageReference(), item.getModel());

              setResponsePage(page);
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
              SurveyAudienceMember surveyAudienceMember = item.getModelObject();

              if (surveyAudienceMember != null)
              {
                removeDialog.show(target, surveyAudienceMember);
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
          "Failed to initialise the SurveyAudienceMemberAdministrationPage", e);
    }
  }

  /**
   * The <code>RemoveDialog</code> class implements a dialog that allows the removal of a
   * survey audience member to be confirmed.
   */
  private class RemoveDialog extends Dialog
  {
    private static final long serialVersionUID = 1000000;
    private UUID id;
    private Label nameLabel;

    /**
     * Constructs a new <code>RemoveDialog</code>.
     *
     * @param tableContainer the table container, which allows the survey audience member table and
     *                       its associated navigator to be updated using AJAX
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
            surveyService.deleteSurveyAudienceMember(id);

            target.add(tableContainer);

            SurveyAudienceMemberAdministrationPage.this.info(
                "Successfully removed the audience member "
                + nameLabel.getDefaultModelObjectAsString());
          }
          catch (Throwable e)
          {
            logger.error(String.format("Failed to remove the survey audience member (%s): %s", id,
                e.getMessage()), e);

            SurveyAudienceMemberAdministrationPage.this.error(
                "Failed to remove the audience member "
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
     * @param target               the AJAX request target
     * @param surveyAudienceMember the survey audience member being removed
     */
    public void show(AjaxRequestTarget target, SurveyAudienceMember surveyAudienceMember)
    {
      id = surveyAudienceMember.getId();

      nameLabel.setDefaultModelObject(surveyAudienceMember.getFirstName() + " "
          + surveyAudienceMember.getLastName());

      target.add(nameLabel);

      super.show(target);
    }
  }
}
