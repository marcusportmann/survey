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
import digital.survey.model.SurveyInstance;
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.data.InjectableLoadableDetachableModel;

import javax.inject.Inject;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>DetachableSurveyInstanceModel</code> class provides a detachable model
 * implementation for the <code>SurveyInstance</code> model class.
 *
 * @author Marcus Portmann
 */
public class DetachableSurveyInstanceModel extends InjectableLoadableDetachableModel<SurveyInstance>
{
  private static final long serialVersionUID = 1000000;

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey instance.
   */
  private UUID id;

  /**
   * Constructs a new <code>DetachableSurveyInstanceModel</code>.
   * <p/>
   * Hidden default constructor to support CDI.
   */
  @SuppressWarnings("unused")
  protected DetachableSurveyInstanceModel() {}

  /**
   * Constructs a new <code>DetachableSurveyInstanceModel</code>.
   *
   * @param surveyInstance the <code>SurveyInstance</code> instance
   */
  public DetachableSurveyInstanceModel(SurveyInstance surveyInstance)
  {
    this(surveyInstance.getId());

    setObject(surveyInstance);
  }

  /**
   * Constructs a new <code>DetachableSurveyInstanceModel</code>.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the
   *           survey instance
   */
  public DetachableSurveyInstanceModel(UUID id)
  {
    this.id = id;
  }

  /**
   * @see org.apache.wicket.model.LoadableDetachableModel#load()
   */
  @Override
  protected SurveyInstance load()
  {
    try
    {
      return surveyService.getSurveyInstance(id);
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(String.format("Failed to load the survey instance (%s)",
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
