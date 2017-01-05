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
import digital.survey.model.SurveyDefinition;
import digital.survey.web.SurveySecurity;
import digital.survey.web.components.SurveyDefinitionInputPanel;
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.pages.WebPageSecurity;
import guru.mmp.application.web.template.pages.TemplateDialogWebPage;
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
 * The <code>UpdateSurveyDefinitionPage</code> class implements the
 * "Update Survey Definition" page for the web application.
 *
 * @author Marcus Portmann
 */
@SuppressWarnings("CdiManagedBeanInconsistencyInspection")
@WebPageSecurity(SurveySecurity.FUNCTION_CODE_SURVEY_ADMINISTRATION)
public class UpdateSurveyDefinitionPage extends TemplateDialogWebPage
{
  /* Logger */
  private static final Logger logger = LoggerFactory.getLogger(UpdateSurveyDefinitionPage.class);
  private static final long serialVersionUID = 1000000;

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * Constructs a new <code>UpdateSurveyDefinitionPage</code>.
   *
   * @param previousPage          the previous page
   * @param surveyDefinitionModel the model for the survey definition
   */
  public UpdateSurveyDefinitionPage(PageReference previousPage,
      IModel<SurveyDefinition> surveyDefinitionModel)
  {
    super("Update Survey Definition");

    try
    {
      Form<SurveyDefinition> updateForm = new Form<>("updateForm", new CompoundPropertyModel<>(
          surveyDefinitionModel));

      updateForm.add(new SurveyDefinitionInputPanel("surveyDefinition", surveyDefinitionModel));

      // The "updateButton" button
      Button updateButton = new Button("updateButton")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        public void onSubmit()
        {
          try
          {
            SurveyDefinition surveyDefinition = updateForm.getModelObject();

            surveyService.saveSurveyDefinition(surveyDefinition);

            setResponsePage(previousPage.getPage());
          }
          catch (Throwable e)
          {
            logger.error("Failed to update the survey definition: " + e.getMessage(), e);
            UpdateSurveyDefinitionPage.this.error("Failed to update the survey definition");
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
      throw new WebApplicationException("Failed to initialise the UpdateSurveyDefinitionPage", e);
    }
  }
}
