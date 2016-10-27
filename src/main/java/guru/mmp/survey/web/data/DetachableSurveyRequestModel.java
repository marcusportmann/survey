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

package guru.mmp.survey.web.data;

//~--- non-JDK imports --------------------------------------------------------

import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.data.InjectableLoadableDetachableModel;
import guru.mmp.survey.model.ISurveyService;
import guru.mmp.survey.model.SurveyRequest;

import javax.inject.Inject;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>DetachableSurveyRequestModel</code> class provides a detachable model
 * implementation for the <code>SurveyRequest</code> model class.
 *
 * @author Marcus Portmann
 */
public class DetachableSurveyRequestModel extends InjectableLoadableDetachableModel<SurveyRequest>
{
  private static final long serialVersionUID = 1000000;

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey request.
   */
  private UUID id;

  /**
   * Constructs a new <code>DetachableSurveyRequestModel</code>.
   * <p/>
   * Hidden default constructor to support CDI.
   */
  @SuppressWarnings("unused")
  protected DetachableSurveyRequestModel() {}

  /**
   * Constructs a new <code>DetachableSurveyRequestModel</code>.
   *
   * @param surveyAudience the <code>SurveyRequest</code> instance
   */
  public DetachableSurveyRequestModel(SurveyRequest surveyAudience)
  {
    this(surveyAudience.getId());

    setObject(surveyAudience);
  }

  /**
   * Constructs a new <code>DetachableSurveyRequestModel</code>.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the
   *           survey request
   */
  public DetachableSurveyRequestModel(UUID id)
  {
    this.id = id;
  }

  /**
   * @see org.apache.wicket.model.LoadableDetachableModel#load()
   */
  @Override
  protected SurveyRequest load()
  {
    try
    {
      return surveyService.getSurveyRequest(id);
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(String.format("Failed to load the survey request (%s)",
        id), e);
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
