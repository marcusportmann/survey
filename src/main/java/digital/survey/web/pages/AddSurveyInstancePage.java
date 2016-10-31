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
import digital.survey.model.SurveyInstance;
import digital.survey.web.SurveySecurity;
import digital.survey.web.components.SurveyInstanceInputPanel;
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.pages.WebPageSecurity;
import guru.mmp.application.web.template.pages.TemplateWebPage;
import org.apache.wicket.PageReference;
import org.apache.wicket.markup.html.form.Button;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.model.CompoundPropertyModel;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.Model;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.inject.Inject;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>AddSurveyInstancePage</code> class implements the
 * "Add Survey Instance" page for the web application.
 *
 * @author Marcus Portmann
 */
@SuppressWarnings("CdiManagedBeanInconsistencyInspection")
@WebPageSecurity(SurveySecurity.FUNCTION_CODE_SURVEY_ADMINISTRATION)
class AddSurveyInstancePage extends TemplateWebPage
{
  /* Logger */
  private static final Logger logger = LoggerFactory.getLogger(AddSurveyInstancePage.class);
  private static final long serialVersionUID = 1000000;

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * Constructs a new <code>AddSurveyInstancePage</code>.
   *
   * @param previousPage        the previous page
   * @param surveyDefinitionId  the Universally Unique Identifier (UUID) used to identify the survey
   *                            definition for the survey instance
   */
  AddSurveyInstancePage(PageReference previousPage, UUID surveyDefinitionId)
  {
    super("Add Survey Instance");

    try
    {
      SurveyDefinition surveyDefinition = surveyService.getLatestVersionOfSurveyDefinition(
          surveyDefinitionId);

      IModel<SurveyInstance> surveyInstanceModel = new Model<>(new SurveyInstance(
          UUID.randomUUID(), "", "", surveyDefinition));

      Form<SurveyInstance> addForm = new Form<>("addForm", new CompoundPropertyModel<>(
          surveyInstanceModel));

      addForm.add(new SurveyInstanceInputPanel("surveyInstance", surveyInstanceModel));

      // The "addButton" button
      Button addButton = new Button("addButton")
      {
        private static final long serialVersionUID = 1000000;

        @Override
        public void onSubmit()
        {
          try
          {
            surveyService.saveSurveyInstance(addForm.getModelObject());

            setResponsePage(previousPage.getPage());
          }
          catch (Throwable e)
          {
            logger.error("Failed to add the survey instance: " + e.getMessage(), e);
            AddSurveyInstancePage.this.error("Failed to add the survey instance");
          }
        }
      };
      addButton.setDefaultFormProcessing(true);
      addForm.add(addButton);

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
      addForm.add(cancelButton);

      add(addForm);
    }
    catch (Throwable e)
    {
      throw new WebApplicationException("Failed to initialise the AddSurveyInstancePage", e);
    }
  }
}
