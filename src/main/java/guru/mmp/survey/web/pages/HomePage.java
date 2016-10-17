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
import guru.mmp.survey.model.ISurveyService;
import org.apache.wicket.markup.html.form.Button;

import javax.inject.Inject;

/**
 * The <code>HomePage</code> class implements the "Home"
 * page for the web application.
 */
@AnonymousOnlyWebPage
public class HomePage 
  extends TemplateWebPage
{
  private static final long serialVersionUID = 1000000;

  /**
   * The Survey Service.
   */
  @Inject
  private ISurveyService surveyService;

  /**
   * Constructs a new <code>HomePage</code>.
   */
  public HomePage()
  {
    super("Home");

    add(new Button("testButton") {

      private static final long serialVersionUID = 1000000;

      @Override
      public void onSubmit()
      {
        String surveyTemplateId = "706fb4a4-8ba8-11e6-ae22-56b6b6499611";

        try
        {
          //SurveyDefinition surveyTemplate = surveyService.getSurveyDefinition(surveyTemplateId);








          //System.out.println(surveyTemplate.toString());


        }
        catch (Throwable e)
        {
          throw new WebApplicationException("Failed to retrieve the survey definition (" + surveyTemplateId + ")", e);
        }

        System.out.println("Hello World!!!");
      }
    });
  }

}
