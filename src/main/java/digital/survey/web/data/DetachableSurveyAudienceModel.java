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
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.data.InjectableLoadableDetachableModel;
import digital.survey.model.SurveyAudience;

import javax.inject.Inject;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>DetachableSurveyAudienceModel</code> class provides a detachable model
 * implementation for the <code>SurveyAudience</code> model class.
 *
 * @author Marcus Portmann
 */
public class DetachableSurveyAudienceModel extends InjectableLoadableDetachableModel<SurveyAudience>
{
  private static final long serialVersionUID = 1000000;

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey audience.
   */
  private UUID id;

  /**
   * Constructs a new <code>DetachableSurveyAudienceModel</code>.
   * <p/>
   * Hidden default constructor to support CDI.
   */
  @SuppressWarnings("unused")
  protected DetachableSurveyAudienceModel() {}

  /**
   * Constructs a new <code>DetachableSurveyAudienceModel</code>.
   *
   * @param surveyAudience the <code>SurveyAudience</code> instance
   */
  public DetachableSurveyAudienceModel(SurveyAudience surveyAudience)
  {
    this(surveyAudience.getId());

    setObject(surveyAudience);
  }

  /**
   * Constructs a new <code>DetachableSurveyAudienceModel</code>.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the
   *           survey audience
   */
  public DetachableSurveyAudienceModel(UUID id)
  {
    this.id = id;
  }

  /**
   * @see org.apache.wicket.model.LoadableDetachableModel#load()
   */
  @Override
  protected SurveyAudience load()
  {
    try
    {
      return surveyService.getSurveyAudience(id);
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(String.format("Failed to load the survey audience (%s)",
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
