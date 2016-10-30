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

package digital.survey.web.data;

//~--- non-JDK imports --------------------------------------------------------

import digital.survey.model.ISurveyService;
import digital.survey.model.SurveyResponseSummary;
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.data.InjectableLoadableDetachableModel;

import javax.inject.Inject;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>DetachableSurveyResponseModel</code> class provides a detachable model
 * implementation for the <code>SurveyResponseSummary</code> model class.
 *
 * @author Marcus Portmann
 */
public class DetachableSurveyResponseSummaryModel
    extends InjectableLoadableDetachableModel<SurveyResponseSummary>
{
  private static final long serialVersionUID = 1000000;

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey response.
   */
  private UUID id;

  /**
   * Constructs a new <code>DetachableSurveyResponseModel</code>.
   * <p/>
   * Hidden default constructor to support CDI.
   */
  @SuppressWarnings("unused")
  protected DetachableSurveyResponseSummaryModel() {}

  /**
   * Constructs a new <code>DetachableSurveyResponseModel</code>.
   *
   * @param surveyResponseSummary the <code>SurveyResponse</code> instance
   */
  public DetachableSurveyResponseSummaryModel(SurveyResponseSummary surveyResponseSummary)
  {
    this(surveyResponseSummary.getId());

    setObject(surveyResponseSummary);
  }

  /**
   * Constructs a new <code>DetachableSurveyResponseModel</code>.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the
   *           survey response
   */
  public DetachableSurveyResponseSummaryModel(UUID id)
  {
    this.id = id;
  }

  /**
   * @see org.apache.wicket.model.LoadableDetachableModel#load()
   */
  @Override
  protected SurveyResponseSummary load()
  {
    try
    {
      return surveyService.getSurveyResponseSummary(id);
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(String.format(
          "Failed to load the summary for the survey response (%s)", id), e);
    }
  }

  /**
   * Invoked when the model is detached after use.
   */
  @Override
  protected void onDetach()
  {
    super.onDetach();

    setObject(null);
  }
}
