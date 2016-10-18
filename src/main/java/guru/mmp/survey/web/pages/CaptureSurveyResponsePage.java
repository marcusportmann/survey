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

import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.pages.AnonymousOnlyWebPage;
import guru.mmp.application.web.template.pages.TemplateWebPage;
import guru.mmp.survey.model.*;
import guru.mmp.survey.web.components.SurveyResponsePanel;
import org.apache.wicket.markup.html.form.Button;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.Model;
import org.apache.wicket.request.mapper.parameter.PageParameters;

import javax.inject.Inject;
import java.util.UUID;

/**
 * The <code>CaptureSurveyResponsePage</code> class implements the "Survey Response"
 * page for the web application.
 *
 * @author Marcus Portmann
 */
@SuppressWarnings("CdiManagedBeanInconsistencyInspection")
public class CaptureSurveyResponsePage
  extends TemplateWebPage
{
  private static final long serialVersionUID = 1000000;

  /**
   * The Survey Service.
   */
  @Inject
  private ISurveyService surveyService;

  /**
   * Constructs a new <code>CaptureSurveyResponsePage</code>.
   *
   * @param pageParameters the page parameters
   */
  public CaptureSurveyResponsePage(PageParameters pageParameters)
  {
    super("Capture Survey Response");


    try
    {
      SurveyInstance surveyInstance = surveyService.getSurveyInstance(UUID.fromString(pageParameters.get("surveyInstanceId").toString()));

      SurveyRequest surveyRequest = null;

      if ((!pageParameters.get("surveyRequestId").isNull()) && (!pageParameters.get("surveyRequestId").isEmpty()))
      {
        surveyRequest = surveyService.getSurveyRequest(UUID.fromString(pageParameters.get("surveyRequestId").toString()));
      }

      SurveyResponse surveyResponse = new SurveyResponse(surveyInstance, surveyRequest);

      IModel<SurveyResponse> surveyResponseModel = new Model<>(surveyResponse);

      add(new SurveyResponsePanel("surveyResponse", surveyResponseModel));


    }
    catch (Throwable e)
    {
      throw new WebApplicationException("Failed to initialise the SurveyResultPage", e);
    }


  }

}
