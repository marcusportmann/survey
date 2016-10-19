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
import guru.mmp.application.web.data.InjectableDataProvider;
import guru.mmp.survey.model.ISurveyService;
import guru.mmp.survey.model.SurveyAudience;
import org.apache.wicket.model.IModel;

import javax.inject.Inject;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyAudienceDataProvider</code> class provides an <code>IDataProvider</code>
 * implementation that retrieves <code>SurveyAudience</code> instances from the database.
 *
 * @author Marcus Portmann
 */
public class SurveyAudienceDataProvider extends InjectableDataProvider<SurveyAudience>
{
  private static final long serialVersionUID = 1000000;

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the organisation the survey
   * audiences are associated with.
   */
  private UUID organisationId;

  /**
   * Constructs a new <code>SurveyAudienceDataProvider</code>.
   * <p/>
   * Hidden default constructor to support CDI.
   */
  @SuppressWarnings("unused")
  protected SurveyAudienceDataProvider() {}

  /**
   * Constructs a new <code>SurveyAudienceDataProvider</code>.
   *
   * @param organisationId the Universally Unique Identifier (UUID) used to uniquely identify the
   *                       organisation the survey audiences are associated with
   */
  public SurveyAudienceDataProvider(UUID organisationId)
  {
    this.organisationId = organisationId;
  }

  /**
   * @see org.apache.wicket.model.IDetachable#detach()
   */
  public void detach() {}

  /**
   * Retrieves the matching survey audiences from the database starting with
   * index <code>first</code> and ending with <code>first+count</code>.
   *
   * @param first the index of the first entry to return
   * @param count the number of the entries to return
   *
   * @return the survey audiences retrieved from the database starting with
   * index <code>first</code> and ending with <code>first+count</code>
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#iterator(long, long)
   */
  public Iterator<SurveyAudience> iterator(long first, long count)
  {
    try
    {
      List<SurveyAudience> allSurveyAudiences = surveyService.getSurveyAudiencesForOrganisation(organisationId);

      return allSurveyAudiences.subList((int) first, (int) Math.min(first + count,
          allSurveyAudiences.size())).iterator();
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(String.format(
          "Failed to load the survey audiences for the organisation (%s) from index (%d) to (%d)",
          organisationId, first, first + count - 1), e);
    }
  }

  /**
   * Wraps the retrieved <code>SurveyAudience</code> POJO with a Wicket model.
   *
   * @param surveyAudience the <code>SurveyAudience</code> instance to wrap
   *
   * @return the Wicket model wrapping the <code>SurveyAudience</code> instance
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#model(java.lang.Object)
   */
  public IModel<SurveyAudience> model(SurveyAudience surveyAudience)
  {
    return new DetachableSurveyAudienceModel(surveyAudience);
  }

  /**
   * Returns the total number of survey audiences.
   *
   * @return the total number of survey audiences
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#size()
   */
  public long size()
  {
    try
    {
      return surveyService.getNumberOfSurveyAudiencesForOrganisation(organisationId);
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(String.format(
          "Failed to retrieve the number of survey audiences for the organisation (%s)",
          organisationId), e);
    }
  }
}
