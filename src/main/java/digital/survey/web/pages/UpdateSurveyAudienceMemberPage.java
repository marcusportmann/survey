/*
 * Copyright 2016 Marcus Portmann
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
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
import digital.survey.model.SurveyAudienceMember;
import digital.survey.web.SurveySecurity;
import digital.survey.web.components.SurveyAudienceMemberInputPanel;
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.pages.WebPageSecurity;
import guru.mmp.application.web.template.pages.TemplateWebPage;
import org.apache.wicket.PageReference;
import org.apache.wicket.markup.html.form.Button;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.model.CompoundPropertyModel;
import org.apache.wicket.model.IModel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.inject.Inject;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>UpdateSurveyAudienceMemberPage</code> class implements the
 * "Update Survey Audience Member" page for the web application.
 *
 * @author Marcus Portmann
 */
@SuppressWarnings("CdiManagedBeanInconsistencyInspection")
@WebPageSecurity(SurveySecurity.FUNCTION_CODE_SURVEY_ADMINISTRATION)
public class UpdateSurveyAudienceMemberPage extends TemplateWebPage
{
  /* Logger */
  private static final Logger logger = LoggerFactory.getLogger(
      UpdateSurveyAudienceMemberPage.class);
  private static final long serialVersionUID = 1000000;

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * Constructs a new <code>UpdateSurveyAudienceMemberPage</code>.
   *
   * @param previousPage              the previous page
   * @param surveyAudienceMemberModel the model for the survey audience member
   */
  public UpdateSurveyAudienceMemberPage(PageReference previousPage,
      IModel<SurveyAudienceMember> surveyAudienceMemberModel)
  {
    super("Update Audience Member");

    try
    {
      Form<SurveyAudienceMember> updateForm = new Form<>("updateForm", new CompoundPropertyModel<>(
          surveyAudienceMemberModel));

      updateForm.add(new SurveyAudienceMemberInputPanel("surveyAudienceMember"));

      // The "updateButton" button
      Button updateButton = new Button("updateButton")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        public void onSubmit()
        {
          try
          {
            surveyService.saveSurveyAudienceMember(updateForm.getModelObject());

            setResponsePage(previousPage.getPage());
          }
          catch (Throwable e)
          {
            logger.error("Failed to update the survey audience member: " + e.getMessage(), e);
            UpdateSurveyAudienceMemberPage.this.error(
                "Failed to update the survey audience member");
          }
        }
      };
      updateButton.setDefaultFormProcessing(true);
      updateForm.add(updateButton);

      // The "cancelButton" button
      Button cancelButton = new Button("cancelButton")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        public void onSubmit()
        {
          setResponsePage(previousPage.getPage());
        }
      };
      cancelButton.setDefaultFormProcessing(false);
      updateForm.add(cancelButton);

      add(updateForm);
    }
    catch (Throwable e)
    {
      throw new WebApplicationException("Failed to initialise the UpdateSurveyAudienceMemberPage",
          e);
    }
  }
}
