///*
// * Copyright 2016 Marcus Portmann
// * All rights reserved.
// *
// * Unless required by applicable law or agreed to in writing, software
// * distributed under the License is distributed on an "AS IS" BASIS,
// * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// * See the License for the specific language governing permissions and
// * limitations under the License.
// */
//
//package digital.survey.web.pages;
//
////~--- non-JDK imports --------------------------------------------------------
//
//import digital.survey.web.SurveySecurity;
//import digital.survey.web.components.SurveyResponseInputPanel;
//import guru.mmp.application.web.WebApplicationException;
//import guru.mmp.application.web.pages.WebPageSecurity;
//import guru.mmp.application.web.template.pages.TemplateWebPage;
//import digital.survey.model.ISurveyService;
//import digital.survey.model.SurveyResponse;
//import org.apache.wicket.PageReference;
//import org.apache.wicket.markup.html.form.Button;
//import org.apache.wicket.markup.html.form.Form;
//import org.apache.wicket.model.CompoundPropertyModel;
//import org.apache.wicket.model.IModel;
//import org.slf4j.Logger;
//import org.slf4j.LoggerFactory;
//
//import javax.inject.Inject;
//import java.util.Date;
//import java.util.UUID;
//
////~--- JDK imports ------------------------------------------------------------
//
///**
// * The <code>AddSurveyResponsePage</code> class implements the "Add Survey Response"
// * page for the web application.
// *
// * @author Marcus Portmann
// */
//@SuppressWarnings("CdiManagedBeanInconsistencyInspection")
//@WebPageSecurity(SurveySecurity.FUNCTION_CODE_SURVEY_ADMINISTRATION)
//public class AddSurveyResponsePage extends TemplateWebPage
//{
//  /* Logger */
//  private static final Logger logger = LoggerFactory.getLogger(AddSurveyResponsePage.class);
//
//  private static final long serialVersionUID = 1000000;
//
//  /**
//   * The Survey Service.
//   */
//  @Inject
//  private ISurveyService surveyService;
//
//  /**
//   * Constructs a new <code>AddSurveyResponsePage</code>.
//   *
//   * @param previousPage       the previous page
//   * @param surveyInstanceId   the Universally Unique Identifier (UUID) used to identify the survey
//   *                           instance the survey result is associated with
//   * @param surveyInstanceName the name of the survey instance
//   */
//  public AddSurveyResponsePage(PageReference previousPage, UUID surveyInstanceId, String surveyInstanceName)
//  {
//    super("Add Survey Response", surveyInstanceName;
//
//    try
//    {
//      Form<SurveyResponse> updateForm = new Form<>("updateForm", new CompoundPropertyModel
//        <SurveyResponse>(surveyResponseModel));
//
//      updateForm.add(new SurveyResponseInputPanel("surveyResponse", surveyResponseModel));
//
//      // The "updateButton" button
//      Button updateButton = new Button("updateButton")
//      {
//        private static final long serialVersionUID = 1000000;
//
//        @Override
//        public void onSubmit()
//        {
//          try
//          {
//            SurveyResponse surveyResponse = updateForm.getModelObject();
//
//            surveyResponse.setResponded(new Date());
//
//            surveyService.saveSurveyResponse(surveyResponse);
//
//            setResponsePage(previousPage.getPage());
//          }
//          catch (Throwable e)
//          {
//            logger.error("Failed to update the survey response: " + e.getMessage(), e);
//            AddSurveyResponsePage.this.error("Failed to update the survey response");
//          }
//        }
//      };
//      updateButton.setDefaultFormProcessing(true);
//      updateForm.add(updateButton);
//
//      // The "cancelButton" button
//      Button cancelButton = new Button("cancelButton")
//      {
//        private static final long serialVersionUID = 1000000;
//
//        @Override
//        public void onSubmit()
//        {
//          setResponsePage(previousPage.getPage());
//        }
//      };
//      cancelButton.setDefaultFormProcessing(false);
//      updateForm.add(cancelButton);
//
//      add(updateForm);
//    }
//    catch (Throwable e)
//    {
//      throw new WebApplicationException("Failed to initialise the AddSurveyResponsePage", e);
//    }
//  }
//}
