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
import digital.survey.model.SendSurveyRequestType;
import digital.survey.model.SurveyAudience;
import digital.survey.model.SurveyInstance;
import digital.survey.web.SurveySecurity;
import digital.survey.web.components.SendSurveyRequestTypeChoiceRenderer;
import digital.survey.web.components.SurveyAudienceChoiceRenderer;
import digital.survey.web.data.FilteredSurveyInstanceDataProvider;
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.WebSession;
import guru.mmp.application.web.pages.WebPageSecurity;
import guru.mmp.application.web.template.components.*;
import guru.mmp.application.web.template.pages.TemplateWebPage;
import org.apache.wicket.PageReference;
import org.apache.wicket.ajax.AjaxRequestTarget;
import org.apache.wicket.ajax.form.AjaxFormComponentUpdatingBehavior;
import org.apache.wicket.ajax.markup.html.AjaxLink;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.form.Button;
import org.apache.wicket.markup.html.form.DropDownChoice;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.form.TextField;
import org.apache.wicket.markup.html.link.Link;
import org.apache.wicket.markup.repeater.Item;
import org.apache.wicket.markup.repeater.ReuseIfModelsEqualStrategy;
import org.apache.wicket.markup.repeater.data.DataView;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.validation.validator.EmailAddressValidator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.inject.Inject;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyInstanceAdministrationPage</code> class implements the
 * "Survey Instance Administration" page for the web application.
 *
 * @author Marcus Portmann
 */
@SuppressWarnings("CdiManagedBeanInconsistencyInspection")
@WebPageSecurity({ SurveySecurity.FUNCTION_CODE_SURVEY_ADMINISTRATION,
    SurveySecurity.FUNCTION_CODE_VIEW_SURVEY_RESPONSE })
class SurveyInstanceAdministrationPage extends TemplateWebPage
{
  /* Logger */
  private static final Logger logger = LoggerFactory.getLogger(
      SurveyInstanceAdministrationPage.class);
  private static final long serialVersionUID = 1000000;

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * Constructs a new <code>SurveyInstanceAdministrationPage</code>.
   *
   * NOTE: The survey instances for all versions of the survey definition with the specified ID
   *       will be shown.
   *
   * @param previousPage         the previous page
   * @param surveyDefinitionId   the Universally Unique Identifier (UUID) used to identify the
   *                             survey definition the survey instances are associated with
   * @param surveyDefinitionName the name of the survey definition
   */
  SurveyInstanceAdministrationPage(PageReference previousPage, UUID surveyDefinitionId,
      String surveyDefinitionName)
  {
    super("Survey Instances", surveyDefinitionName);

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

      // The dialog used to confirm the removal of a survey instance
      RemoveDialog removeDialog = new RemoveDialog(tableContainer);
      add(removeDialog);

      // The dialog used to send a survey request to a single person or a survey audience
      SendSurveyRequestDialog sendSurveyRequestDialog = new SendSurveyRequestDialog();
      add(sendSurveyRequestDialog);

      // The "addLink" used to add a new survey instance
      Link<Void> addLink = new Link<Void>("addLink")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        public void onClick()
        {
          setResponsePage(new AddSurveyInstancePage(getPageReference(), surveyDefinitionId));
        }
      };
      tableContainer.add(addLink);

      FilteredSurveyInstanceDataProvider dataProvider = new FilteredSurveyInstanceDataProvider(
          surveyDefinitionId);

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

      // The survey instance data view
      DataView<SurveyInstance> dataView = new DataView<SurveyInstance>("surveyInstance",
          dataProvider)
      {
        private static final long serialVersionUID = 1000000;

        @Override
        protected void populateItem(Item<SurveyInstance> item)
        {
          item.add(new Label("name", new PropertyModel<String>(item.getModel(), "name")));
          item.add(new Label("version", new PropertyModel<String>(item.getModel(),
              "definition.version")));

          // The "sendSurveyRequestLink" link
          AjaxLink<Void> sendSurveyRequestLink = new AjaxLink<Void>("sendSurveyRequestLink")
          {
            private static final long serialVersionUID = 1000000;

            @Override
            public void onClick(AjaxRequestTarget target)
            {
              SurveyInstance surveyInstance = item.getModelObject();

              if (surveyInstance != null)
              {
                sendSurveyRequestDialog.show(target, surveyInstance);
              }
              else
              {
                target.add(tableContainer);
              }
            }
          };
          item.add(sendSurveyRequestLink);

          // The "surveyRequestsLink" link
          Link<Void> surveyRequestsLink = new Link<Void>("surveyRequestsLink")
          {
            private static final long serialVersionUID = 1000000;

            @Override
            public void onClick()
            {
              SurveyInstance surveyInstance = item.getModelObject();

              setResponsePage(new SurveyRequestAdministrationPage(getPageReference(),
                  surveyInstance.getId(), surveyInstance.getName()));
            }
          };
          item.add(surveyRequestsLink);

          // The "surveyResponsesLink" link
          Link<Void> surveyResponsesLink = new Link<Void>("surveyResponsesLink")
          {
            private static final long serialVersionUID = 1000000;

            @Override
            public void onClick()
            {
              SurveyInstance surveyInstance = item.getModelObject();

              setResponsePage(new SurveyResponseAdministrationPage(getPageReference(),
                  surveyInstance.getId(), surveyInstance.getName()));
            }
          };
          item.add(surveyResponsesLink);

          // The "surveyResultLink" link
          AjaxLink<Void> surveyResultLink = new AjaxLink<Void>("surveyResultLink")
          {
            private static final long serialVersionUID = 1000000;

            @Override
            public void onClick(AjaxRequestTarget target)
            {
              SurveyInstance surveyInstance = item.getModelObject();

              ViewSurveyResultPage page = new ViewSurveyResultPage(getPageReference(),
                surveyInstance.getId(), surveyInstance.getName());

              setResponsePage(page);
            }
          };
          item.add(surveyResultLink);

          // The "updateLink" link
          Link<Void> updateLink = new Link<Void>("updateLink")
          {
            private static final long serialVersionUID = 1000000;

            @Override
            public void onClick()
            {
              UpdateSurveyInstancePage page = new UpdateSurveyInstancePage(getPageReference(),
                  item.getModel());

              setResponsePage(page);
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
              SurveyInstance surveyInstance = item.getModelObject();

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
          "Failed to initialise the SurveyInstanceAdministrationPage", e);
    }
  }

  /**
   * The <code>RemoveDialog</code> class implements a dialog that allows the removal of a
   * survey instance to be confirmed.
   */
  private class RemoveDialog extends Dialog
  {
    private static final long serialVersionUID = 1000000;
    private UUID id;
    private Label nameLabel;

    /**
     * Constructs a new <code>RemoveDialog</code>.
     *
     * @param tableContainer the table container, which allows the survey instance table and its
     *                       associated navigator to be updated using AJAX
     */
    RemoveDialog(WebMarkupContainer tableContainer)
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
            surveyService.deleteSurveyInstance(id);

            target.add(tableContainer);

            SurveyInstanceAdministrationPage.this.info("Successfully removed the survey instance "
                + nameLabel.getDefaultModelObjectAsString());
          }
          catch (Throwable e)
          {
            logger.error(String.format("Failed to remove the survey instance (%s): %s", id,
                e.getMessage()), e);

            SurveyInstanceAdministrationPage.this.error("Failed to remove the survey instance "
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
     * @param surveyInstance the survey instance being removed
     */
    void show(AjaxRequestTarget target, SurveyInstance surveyInstance)
    {
      id = surveyInstance.getId();

      nameLabel.setDefaultModelObject(surveyInstance.getName());

      target.add(nameLabel);

      super.show(target);
    }
  }


  /**
   * The <code>SendSurveyRequestDialog</code> class implements a dialog that provides the capability
   * to send a survey request to a single person or a survey audience.
   */
  private class SendSurveyRequestDialog extends FormDialog
  {
    private static final long serialVersionUID = 1000000;
    private SurveyAudience audience = null;
    private String firstName = null;
    private String lastName = null;
    private String email = null;
    @SuppressWarnings("unused")
    private SendSurveyRequestType sendSurveyRequestType;
    private DropDownChoice<SendSurveyRequestType> sendSurveyRequestTypeField;
    private WebMarkupContainer toPersonContainer;
    private WebMarkupContainer toAudienceContainer;
    private DropDownChoice<SurveyAudience> audienceField;
    private TextField<String> firstNameField;
    private TextField<String> lastNameField;
    private TextField<String> emailField;
    private UUID id;
    private String name;
    private TextField<UUID> nameField;

    /**
     * Constructs a new <code>SendSurveyRequestDialog</code>.
     */
    SendSurveyRequestDialog()
    {
      super("sendSurveyRequestDialog", "Send Survey Request", "Send", "Cancel");

      try
      {
        // The "name" field
        nameField = new TextField<>("name", new PropertyModel<>(this, "name"));
        nameField.setRequired(false);
        nameField.setEnabled(false);
        nameField.setOutputMarkupId(true);
        getForm().add(nameField);

        SendSurveyRequestTypeChoiceRenderer sendSurveyRequestTypeChoiceRenderer =
            new SendSurveyRequestTypeChoiceRenderer();

        // The "sendSurveyRequestType" field
        sendSurveyRequestTypeField = new DropDownChoiceWithFeedback<>("sendSurveyRequestType",
            new PropertyModel<>(this, "sendSurveyRequestType"), getSendSurveyRequestTypeOptions(),
            sendSurveyRequestTypeChoiceRenderer);
        sendSurveyRequestTypeField.setRequired(true);
        sendSurveyRequestTypeField.setOutputMarkupId(true);
        getForm().add(sendSurveyRequestTypeField);

        sendSurveyRequestTypeField.add(new AjaxFormComponentUpdatingBehavior("change")
            {
              private static final long serialVersionUID = 1000000;

              @Override
              protected void onUpdate(AjaxRequestTarget target)
              {
                try
                {
                  target.add(sendSurveyRequestTypeField);

                  resetContainers(target);
                }
                catch (Throwable e)
                {
                  throw new RuntimeException("Failed to update the sendSurveyRequestType field", e);
                }
              }
            });

        // The "toAudienceContainer" container
        setupToAudienceContainer();

        // The "toPersonContainer" container
        setupToPersonContainer();
      }
      catch (Throwable e)
      {
        throw new WebApplicationException("Failed to initialise the SendSurveyRequestDialog", e);
      }
    }

    /**
     * Show the dialog using Ajax.
     *
     * @param target the AJAX request target
     */
    public void show(AjaxRequestTarget target, SurveyInstance surveyInstance)
    {
      super.show(target);

      id = surveyInstance.getId();

      name = surveyInstance.getName();

      target.add(nameField);
    }

    /**
     * Process the cancellation of the form associated with the dialog.
     *
     * @param target the AJAX request target
     * @param form   the form
     */
    @Override
    protected void onCancel(AjaxRequestTarget target, Form form) {}

    /**
     * Process the submission of the form associated with the dialog.
     *
     * @param target the AJAX request target
     * @param form   the form
     */
    @Override
    protected void onSubmit(AjaxRequestTarget target, Form form)
    {
      try
      {
        if (SendSurveyRequestType.AUDIENCE.getCodeAsString().equals(
            sendSurveyRequestTypeField.getValue()))
        {
          surveyService.sendSurveyRequestToAudience(id, audience);

          SurveyInstanceAdministrationPage.this.info(String.format(
              "Successfully sent the survey request to %s", audience.getName()));
        }
        else
        {
          surveyService.sendSurveyRequestToPerson(id, firstName, lastName, email);

          SurveyInstanceAdministrationPage.this.info(String.format(
              "Successfully sent the survey request to %s %s", firstName, lastName));
        }

      }
      catch (Throwable e)
      {
        logger.error("Failed to send the survey request: " + e.getMessage(), e);

        if (SendSurveyRequestType.AUDIENCE.getCodeAsString().equals(
            sendSurveyRequestTypeField.getValue()))
        {
          SurveyInstanceAdministrationPage.this.error(String.format(
              "Failed to the survey request to %s", audience.getName()));
        }
        else
        {
          SurveyInstanceAdministrationPage.this.info(String.format(
              "Failed to send the survey request to %s %s", firstName, lastName));
        }
      }

      resetDialog(target);

      target.add(getAlerts());

      hide(target);
    }

    /**
     * Reset the model for the dialog.
     */
    protected void resetDialogModel()
    {
      sendSurveyRequestType = null;
    }

    private List<SurveyAudience> getAudienceOptions()
      throws WebApplicationException
    {
      WebSession session = getWebApplicationSession();

      try
      {
        return surveyService.getSurveyAudiencesForOrganisation(session.getOrganisation().getId());
      }
      catch (Throwable e)
      {
        throw new WebApplicationException(
            "Failed to retrieve the survey audiences for the organisation ("
            + session.getOrganisation().getId() + ")", e);
      }
    }

    private List<SendSurveyRequestType> getSendSurveyRequestTypeOptions()
    {
      List<SendSurveyRequestType> sendSurveyRequestTypes = new ArrayList<>();

      sendSurveyRequestTypes.add(SendSurveyRequestType.AUDIENCE);
      sendSurveyRequestTypes.add(SendSurveyRequestType.PERSON);

      return sendSurveyRequestTypes;
    }

    private void resetContainers(AjaxRequestTarget target)
    {
      // Reset the "toPersonContainer"
      firstNameField.setModelObject(null);
      lastNameField.setModelObject(null);
      emailField.setModelObject(null);

      target.add(toPersonContainer);

      // Reset the "toAudienceContainer"
      audienceField.setModelObject(null);

      target.add(toAudienceContainer);
    }

    private void setupToAudienceContainer()
    {
      toAudienceContainer = new WebMarkupContainer("toAudienceContainer")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        protected void onConfigure()
        {
          super.onConfigure();

          setVisible(SendSurveyRequestType.AUDIENCE.getCodeAsString().equals(
              sendSurveyRequestTypeField.getValue()));
        }
      };

      toAudienceContainer.setOutputMarkupId(true);
      toAudienceContainer.setOutputMarkupPlaceholderTag(true);
      getForm().add(toAudienceContainer);

      SurveyAudienceChoiceRenderer surveyAudienceChoiceRenderer =
          new SurveyAudienceChoiceRenderer();

      // The "audience" field
      audienceField = new DropDownChoiceWithFeedback<SurveyAudience>("audience",
          new PropertyModel<>(this, "audience"), getAudienceOptions(), surveyAudienceChoiceRenderer)
      {
        @Override
        protected void onConfigure()
        {
          super.onConfigure();

          setRequired(SendSurveyRequestType.AUDIENCE.getCodeAsString().equals(
              sendSurveyRequestTypeField.getValue()));
        }
      };
      audienceField.setOutputMarkupId(true);
      toAudienceContainer.add(audienceField);
    }

    private void setupToPersonContainer()
    {
      toPersonContainer = new WebMarkupContainer("toPersonContainer")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        protected void onConfigure()
        {
          super.onConfigure();

          setVisible(SendSurveyRequestType.PERSON.getCodeAsString().equals(
              sendSurveyRequestTypeField.getValue()));
        }
      };

      toPersonContainer.setOutputMarkupId(true);
      toPersonContainer.setOutputMarkupPlaceholderTag(true);
      getForm().add(toPersonContainer);

      // The "firstName" field
      firstNameField = new TextFieldWithFeedback<String>("firstName", new PropertyModel<>(this,
          "firstName"))
      {
        @Override
        protected void onConfigure()
        {
          super.onConfigure();

          setRequired(SendSurveyRequestType.PERSON.getCodeAsString().equals(
              sendSurveyRequestTypeField.getValue()));
        }
      };
      firstNameField.setOutputMarkupId(true);
      toPersonContainer.add(firstNameField);

      // The "lastName" field
      lastNameField = new TextFieldWithFeedback<String>("lastName", new PropertyModel<>(this,
          "lastName"))
      {
        @Override
        protected void onConfigure()
        {
          super.onConfigure();

          setRequired(SendSurveyRequestType.PERSON.getCodeAsString().equals(
              sendSurveyRequestTypeField.getValue()));
        }
      };
      lastNameField.setOutputMarkupId(true);
      toPersonContainer.add(lastNameField);

      // The "email" field
      emailField = new TextFieldWithFeedback<String>("email", new PropertyModel<>(this, "email"))
      {
        @Override
        protected void onConfigure()
        {
          super.onConfigure();

          setRequired(SendSurveyRequestType.PERSON.getCodeAsString().equals(
              sendSurveyRequestTypeField.getValue()));
        }
      };
      emailField.add(EmailAddressValidator.getInstance());
      emailField.setOutputMarkupId(true);
      toPersonContainer.add(emailField);
    }
  }
}
